CWD := $(shell pwd)
INSTALLDIR := "/usr/bin/"


all: run test

build:
	@echo ====================================
	@echo Building LHCompiler binary...
	@echo ====================================
	@echo
	@dotnet build -c Debug src/LHCompiler/ -o ./bin/LHCompiler/
	@echo
	@echo ====================================
	@echo building LHGenDes binary...
	@echo ====================================
	@echo
	@dotnet build -c Debug src/LHGenDes/ -o ./bin/LHGenDes/

install:
	@echo ======================================================
	@echo Creating a symbolic link to Ackix compiler executables
	@echo ======================================================
	sudo ln -fs "$(CWD)/bin/LHCompiler/Ackix" $(INSTALLDIR)/Ackix
	sudo ln -fs "$(CWD)/bin/LHCompiler/AckixMessage.fsx" $(INSTALLDIR)/AckixMessage.fsx
	sudo ln -fs "$(CWD)/bin/LHCompiler/AckixExpr.fsx" $(INSTALLDIR)/AckixExpr.fsx
	@echo
	@echo Done. Execute 'Ackix' to run Ackix compiler.
	@echo
	@echo

uninstall:
	@echo =====================================================
	@echo Removing symbolic links to Ackix compiler executables
	@echo =====================================================
	sudo rm -f $(INSTALLDIR)/Ackix
	sudo rm -f $(INSTALLDIR)/AckixMessage.fsx
	sudo rm -f $(INSTALLDIR)/AckixExpr.fsx
	@echo

clean:
	@find . -type d -name 'bin' | xargs rm -rf
	@find . -type d -name 'obj' | xargs rm -rf

test: test_tvm test_lhm test_parser test_ti test_comp test_interop

test_interop:
	@dotnet test ./tests/SDKInteropTests/

test_parser:
	@dotnet test ./tests/ParserTests

test_lhm:
	@dotnet test ./tests/LHMachineTests

test_tvm:
	@dotnet test ./tests/TVMTests

test_lht:
	@dotnet test ./tests/LHTypesTests

test_ti:
	@dotnet test ./tests/LHTypeInferTests

test_comp:
	@dotnet test ./tests/LHCompilerTests

comp:
	@dotnet build ./src/LHCompiler/