#!/bin/bash

cd ${STEAMAPPDIR}

######################################
#                                    #
# Process the arguments in variables #
#                                    #
######################################
ARGS=""

# Disables Steam integration on server.
# - Default: Enabled
if [ "${NOSTEAM}" == "1" ] || [ "${NOSTEAM,,}" == "true" ]; then
  ARGS="${ARGS} -nosteam"
fi

# Sets the path for the game data cache dir.
# - Default: ~/Zomboid
# - Example: /server/Zomboid/data
if [ "${CACHEDIR}" != "" ]; then
  ARGS="${ARGS} -cachedir=${CACHEDIR}"
fi

# Option to control where mods are loaded from. Any of the 3 keywords may be left out and may appear in any order.
# - Default: workshop,steam,mods
# - Example: mods,steam
if [ "${MODFOLDERS}" != "" ]; then
  ARGS="${ARGS} -modfolders ${MODFOLDERS}"
fi

# Launches the game in debug mode.
# - Default: Disabled
if [ "${DEBUG}" == "1" ] || [ "${DEBUG,,}" == "true" ]; then
  ARGS="${ARGS} -debug"
fi

# Option to bypasses the enter-a-password prompt when creating a server.
# This option is mandatory the first startup or will be asked in console and startup will fail.
# Once is launched and data is created, then can be removed without problem.
# Is recommended to remove it, because the server logs the arguments in clear text, so Admin password will be sent to log in every startup.
if [ "${ADMINPASSWORD}" != "" ]; then
  ARGS="${ARGS} -adminpassword ${ADMINPASSWORD}"
fi

# You can choose a different servername by using this option when starting the server.
if [ "${SERVERNAME}" != "" ]; then
  ARGS="${ARGS} -servername ${SERVERNAME}"
else
  # If not servername is set, use the default name in the next step
  SERVERNAME="servertest"
fi

# If server config doesn't exists, presset is set and preset file exists, the new servername config will be created using that presset
if [ ! -f "${HOME}/Zomboid/Server/${SERVERNAME}_SandboxVars.lua" ] && [ "${SERVERPRESET}" != "" ] && [ -f "${STEAMAPPDIR}/media/lua/shared/Sandbox/${SERVERPRESET}.lua" ]; then
  echo "*** INFO: New server will be created using the preset ${SERVERPRESET} ***"
  echo "*** Copying preset file from \"${STEAMAPPDIR}/media/lua/shared/Sandbox/${SERVERPRESET}.lua\" to \"${HOME}/Zomboid/Server/${SERVERNAME}_SandboxVars.lua\" ***"
  mkdir -p "${HOME}/Zomboid/Server/"
  cp "${STEAMAPPDIR}/media/lua/shared/Sandbox/${SERVERPRESET}.lua" "${HOME}/Zomboid/Server/${SERVERNAME}_SandboxVars.lua"
  sed -i "1s/return.*/SandboxVars = \{/" "${HOME}/Zomboid/Server/${SERVERNAME}_SandboxVars.lua"
  # Remove carriage return
  dos2unix "${HOME}/Zomboid/Server/${SERVERNAME}_SandboxVars.lua"
fi

# Option to handle multiple network cards. Example: 127.0.0.1
if [ "${IP}" != "" ]; then
  ARGS="${IP} -ip ${IP}"
fi

# Set the DefaultPort for the server. Example: 16261
if [ "${PORT}" != "" ]; then
  ARGS="${ARGS} -port ${PORT}" 
fi

# Option to enable/disable VAC on Steam servers. On the server command-line use -steamvac true/false. In the server's INI file, use STEAMVAC=true/false.
if [ "${STEAMVAC}" != "" ]; then
  ARGS="${ARGS} -steamvac ${STEAMVAC}"
fi

# Steam servers require two additional ports to function (I'm guessing they are both UDP ports, but you may need TCP as well).
# These are in addition to the DefaultPort= setting. These can be specified in two ways:
#  - In the server's INI file as SteamPort1= and SteamPort2=.
#  - Using STEAMPORT1 and STEAMPORT2 variables.
if [ "${STEAMPORT1}" != "" ]; then
  ARGS="${ARGS} -steamport1 ${STEAMPORT1}"
fi
if [ "${STEAMPORT2}" != "" ]; then
  ARGS="${ARGS} -steamport2 ${STEAMPORT1}"
fi

# Set the server memory. Units are accepted (1024m=1Gig, 2048m=2Gig, 4096m=4Gig): Example: 1024m
if [ "${MEMORY}" != "" ]; then
  ARGS="${ARGS} -Xmx${MEMORY} -Xms${MEMORY}" 
fi

# Option to perform a Soft Reset
if [ "${SOFTRESET}" == "1" ] || [ "${SOFTRESET,,}" == "true" ]; then
  ARGS="${ARGS} -Dsoftreset" 
fi

# Fix to a bug in start-server.sh that causes to no preload a library:
# ERROR: ld.so: object 'libjsig.so' from LD_PRELOAD cannot be preloaded (cannot open shared object file): ignored.
export LD_LIBRARY_PATH="${STEAMAPPDIR}/jre64/lib:${LD_LIBRARY_PATH}"

bash start-server.sh ${ARGS}