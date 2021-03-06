set (FOUND_OS "Unknown")
set (OS_LINUX 0)
set (OS_FBSD 0)
set (OS_WIN32 0)
set (OS_MACOS 0)

IF(${CMAKE_SYSTEM_NAME} MATCHES "Windows")
	set (OS_WIN32 1)
	set (FLAGS --define=WIN32)
	set (FOUND_OS "Windows")
ENDIF()
IF(${CMAKE_SYSTEM_NAME} MATCHES "FreeBSD")
	set (OS_FBSD 1)
	set (FLAGS --define=FBSD)
	set (FOUND_OS "FreeBSD")
ENDIF()
IF(${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
	set (OS_MACOS 1)
	set (FOUND_OS "macOS")
ENDIF()
IF(${CMAKE_SYSTEM_NAME} MATCHES "Linux")
	set (OS_LINUX 1)
	set (FOUND_OS "Linux")
ENDIF()
