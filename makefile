MEXRUN    = $(MATLAB)/bin/mex

ifndef CONFIG   
  CONFIG = Release
endif

# Compiler flags
CFLAGS   = -Wall -std=gnu11
CXXFLAGS = -Wall -std=gnu++11 

LDFLAGS    = -w -Wl,--no-undefined \
             -L$(LD_LIBRARY_PATH)

LDCXXFLAGS = -w -Wl,--no-undefined \
             -L$(LD_LIBRARY_PATH)

ifeq "$(CONFIG)" "Release"
  OBJ_DIR 	= ./obj/Release
  DEP_DIR 	= ./dep/Release
  OUT_DIR 	= ./mex/Release
  CFLAGS   += -O -DNDEBUG 
  CXXFLAGS += -O -DNDEBUG 
endif

ifeq "$(CONFIG)" "Debug"
  OBJ_DIR 	= ./obj/Debug
  DEP_DIR 	= ./dep/Debug
  OUT_DIR 	= ./mex/Debug
  CFLAGS   += -gdwarf-2 -O0
  CXXFLAGS += -gdwarf-2 -O0
endif


MEXFLAGS = GCC='$$GCC'						\
			  CC='$$CC'  						\
			  CFLAGS='$$CFLAGS'	         \
			  CXX='$$CXX' 						\
			  CXXFLAGS='$$CXXFLAGS'       \
			  LD='$$CC'  						\
			  LDFLAGS='$$LDFLAGS'			\
			  LDCXX='$$CXX'					\
			  LDCXXFLAGS='$$LDCXXFLAGS'	\
			  -compatibleArrayDims 			\
			  -silent			
		
DEPFLAGS = GCC='$$GCC'						\
			  CC='$$CC'            			\
			  CFLAGS='$$CFLAGS -MM'       \
			  CXX='$$CXX'			 			\
			  CXXFLAGS='$$CXXFLAGS -M'	   \
			  -compatibleArrayDims 			\
			  -silent				
			
# Specify -v for verbose mode

## Sources definition 
SRC_C_DIR01 = ./src

# First file in the SRC_C or SRC_CPP list corresponds to mex filename 
SRC_C     =    $(SRC_C_DIR01)/myFirstMex.c	\
		    	   $(SRC_C_DIR01)/proc.c

SRC_CPP  =

## Include folders
INC_C	 = -I./inc
INC_CPP  = -I./inc

ifeq "$(CONFIG)" "Release"
  OBJ_DIR 	= ./obj/Release
  DEP_DIR 	= ./dep/Release
  OUT_DIR 	= ./mex/Release
  MEXFLAGS += -O
endif

ifeq "$(CONFIG)" "Debug"
  OBJ_DIR 	= ./obj/Debug
  DEP_DIR 	= ./dep/Debug
  OUT_DIR 	= ./mex/Debug
  MEXFLAGS += -g
endif

# Change list specification if you need mex filename to be from the different src list 
MEX_OUT = $(addsuffix .$(shell $(MATLAB)/bin/mexext), $(basename $(notdir $(word 1, $(SRC_C)))))

## Object files
OBJ_C	  = $(join $(addsuffix ../$(OBJ_DIR)/, $(dir $(SRC_C))),   $(addsuffix .o, $(basename $(notdir $(SRC_C)  ))))
OBJ_CPP = $(join $(addsuffix ../$(OBJ_DIR)/, $(dir $(SRC_CPP))), $(addsuffix .o, $(basename $(notdir $(SRC_CPP)))))

## Dependency destination is ../dep relative to the src dir	
DEP_C	  = $(join $(addsuffix ../$(DEP_DIR)/, $(dir $(SRC_C))),   $(addsuffix .d, $(basename $(notdir $(SRC_C)  ))))
DEP_CPP = $(join $(addsuffix ../$(DEP_DIR)/, $(dir $(SRC_CPP))), $(addsuffix .d, $(basename $(notdir $(SRC_CPP)))))

## Default rule executed
all: $(OUT_DIR)/$(MEX_OUT)
	@true

## Clean Rule
.PHONY: clean
clean:
	@rm -f $(OUT_DIR)/$(MEX_OUT) $(OBJ_C) $(DEP_C)
	
## Rule for making the actual target
$(OUT_DIR)/$(MEX_OUT): $(OBJ_C)
	@echo "LD  $@"
	@$(MEXRUN) $(MEXFLAGS) $(INC_C) -outdir $(OUT_DIR) -output $(MEX_OUT) $(word 1, $(SRC_C)) $(wordlist 2, $(words $^), $^)
	@echo -- Link finished --	

## Generic compilation rule
%.o : %.c
	@mkdir -p $(dir $@)
	@echo "CC  $<"
	@$(MEXRUN) $(MEXFLAGS) $(INC_C) -c -outdir $(OBJ_DIR) $< 

## Rules for object files from cpp files (1 rule for each SRC dir )
## Object file for each src file is put into obj directory
## one level up from the actual source directory.
$(SRC_C_DIR01)/../$(OBJ_DIR)/%.o : $(SRC_C_DIR01)/%.c
	@mkdir -p $(dir $@)
	@echo "CC  $<"
	@$(MEXRUN) $(MEXFLAGS) $(INC_C) -c -outdir $(OBJ_DIR) $<
	
## Make dependancy rules (1 rule for each SRC dir )
$(SRC_C_DIR01)/../$(DEP_DIR)/%.d : $(SRC_C_DIR01)/%.c
	@mkdir -p $(dir $@)
	@echo "DEP $*.o"
	@$(MEXRUN) $(DEPFLAGS) $(INC_C) -c -outdir $(DEP_DIR) $<
	@mv -f $(DEP_DIR)/$*.o $(DEP_DIR)/$*.d.tmp
	@sed -e 's|$*.o:|$(SRC_C_DIR01)/../$(OBJ_DIR)/$*.o:|' < $(DEP_DIR)/$*.d.tmp > $(DEP_DIR)/$*.d
	@sed -e 's/.*://' -e 's/\\$$//' < $(DEP_DIR)/$*.d.tmp | fmt -1 | \
	 sed -e 's/^ *//' -e 's/$$/:/' >> $(DEP_DIR)/$*.d
	@rm -f $(DEP_DIR)/$*.d.tmp 

## Include the dependency files
-include $(DEP_C)

