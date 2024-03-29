# tested with XCELIUM 18.09

# Commmand arguments:
# -g option starts xrun simulation with gui, with separate database

# To set the paths for xrun and imc, execute the following command in the terminal:
 source /cad/env/cadence_path.XCELIUM1809

# Help library if available with command:
# cdnshelp &

#------------------------------------------------------------------------------
# test name
TESTS=(lab01);
#------------------------------------------------------------------------------
# MAIN
function main(){
  xrun_compile
  xrun_elaborate
  xrun_run_all_tests
  run_imc
}
#------------------------------------------------------------------------------
# local variables#<<<
INCA="INCA_libs"
GUI=""
#>>>
#------------------------------------------------------------------------------
# check input script arguments#<<<
while getopts gh option
  do case "${option}" in
    g) GUI="+access+r +gui"; INCA="${INCA}_gui";;
    *) echo "The only valid option is -g (for GUI)"; exit -1 ;;
  esac
done
#>>>
#------------------------------------------------------------------------------
# init #<<<
rm -rf $INCA      # remove previous database
rm -rf cov_work   # remove previous coverage results
cols=`tput cols`
separator=`perl -e "print \"#\" x $cols"`
#>>>
#------------------------------------------------------------------------------
# simulator arguments #<<<
XRUN_ARGS="\
  -f alu_mtm.f \
  -f alu_tb.f \
  -v93 \
  +nowarnDSEM2009 \
  +nowarnDSEMEL \
  +nowarnCGDEFN \
  -xmlibdirname $INCA \
  $GUI \
  +overwrite \
  -nocopyright \
  -coverage all \
  -covoverwrite \
  -covfile xrun_covfile.txt \
"
#>>>
#------------------------------------------------------------------------------
# PROCEDURES
#------------------------------------------------------------------------------
function xrun_info() { #<<<
  # Prints string between separators
  # args: string
  echo $separator
  echo "$*"
  echo $separator
  return 0
} #>>>
#------------------------------------------------------------------------------
function xrun_check_status() { #<<<
  # Checks the status of the action;
  # args: int (status), string (action name)

  status=$1
  action=$2

  if [[ "$status" != "0" ]]; then
    echo "$action failed with status $status".
    exit -1
  fi
  echo $action finished with status 0.
  return 0
} #>>>
#------------------------------------------------------------------------------
function xrun_compile() { #<<<
  xrun_info "# Compiling. Log saved to xrun_compile.log"
  xrun -compile -l xrun_compile.log $XRUN_ARGS 
  xrun_check_status $? "Compilation"
} #>>>
#------------------------------------------------------------------------------
function xrun_elaborate() { #<<<
  xrun_info "# Elaborating. Log saved to xrun_elaborate.log"
  xrun -elaborate  -l xrun_elaborate.log $XRUN_ARGS
  xrun_check_status $? "Elaboration"
} #>>>
#------------------------------------------------------------------------------
function xrun_run_all_tests() { #<<<
  if [[ "$GUI" != "" ]] ; then
      xrun $XRUN_ARGS \
        -covtest ${TESTS[0]} \
        -l xrun_gui.log
#        +UVM_TESTNAME=${TESTS[0]} \
  else  
    TEST_LIST=""

    for TEST in ${TESTS[@]} ; do
      TEST_LIST="$TEST_LIST $TEST"
      xrun_info "# Running test: $TEST. Log saved to xrun_test_$TEST.log"
      # run the simulation
      xrun $XRUN_ARGS \
        -covtest $TEST \
        -l xrun_test_$TEST.log
#        +UVM_TESTNAME=$TEST \
      xrun_check_status $? "Test $TEST"
    done

    echo "# End of tests."
  fi
} #>>>
#------------------------------------------------------------------------------
function run_imc { #<<<
  xrun_info "# Running imc."
  #------------------------------------------------------------------------------
  # print the coverage results summary (non-GUI mode)
  if [[ "$GUI" == "" ]] ; then

    # merging the coverage results from different tests
    imc -nocopyright -batch -initcmd \
      "load -run $TEST; merge -out merged_results $TEST_LIST; exit" |& tee xrun_cov.rpt
    xrun_check_status $? "IMC MERGE"

    # printing the summary
    imc -nocopyright -batch -initcmd \
      "load -run merged_results; report -summary; exit" |& tee -a xrun_cov.rpt
    xrun_check_status $? "IMC REPORT"

    xrun_info "\
 The coverage report was saved to xrun_cov.rpt file.
 To browse the results with gui use:
   imc -load merged_results"
  fi
} #>>>
#------------------------------------------------------------------------------
# run the main
main

# vim: fdm=marker foldmarker=<<<\,>>>
