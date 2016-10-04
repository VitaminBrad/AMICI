cd .\SuiteSparse\SuiteSparse_config

mingw32-make library -e CC="gcc"

cd .\..\AMD

$CurrentDir = $(get-location).Path;

mingw32-make library -e CC="gcc" 

cd .\..\BTF

mingw32-make library -e CC="gcc" 

cd .\..\CAMD

mingw32-make library -e CC="gcc" 

cd .\..\COLAMD

mingw32-make library -e CC="gcc"  

cd .\..\KLU

mingw32-make library -e CC="gcc" 


mkdir .\..\..\sundials\build\
cd .\..\..\sundials\build\

cmake .. -DCMAKE_INSTALL_PREFIX="$CMAKE_SOURCE_DIR/../build/sundials" `
-DBUILD_ARKODE=OFF `
-DBUILD_CVODE=OFF `
-DBUILD_IDA=OFF `
-DBUILD_KINSOL=OFF `
-DBUILD_SHARED_LIBS=ON `
-DBUILD_STATIC_LIBS=OFF `
-DEXAMPLES_ENABLE=OFF `
-DEXAMPLES_INSTALL=OFF `
-DKLU_ENABLE=ON `
-DKLU_LIBRARY_DIR="$CMAKE_SOURCE_DIR/../SuiteSparse/lib" `
-DKLU_INCLUDE_DIR="$CMAKE_SOURCE_DIR/../SuiteSparse/include" `

msbuild ALL BUILD.vcxproj
msbuild INSTALL.vcxproj

ls

cd ..

cmake CMakeLists.txt
mingw32-make -e CXX="g++"

ls

if ( (Test-Path ".\main.exe") -eq $false)
{
	throw "build unsuccessfull"
}