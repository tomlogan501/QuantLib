#!/bin/bash

#rm tmp/ coverage/ -r
mkdir -p coverage tmp
find -name *.gcda -exec rm {} \;
rm ./tmp/lcov_run.info
rm ./tmp/lcov_total.info

lcov --no-external --capture --initial --directory . --output-file ./tmp/lcov_base.info

./test-suite/quantlib-test-suite --show_progress=TRUE --run_test=*/Time* --run_test=*/Instrument* --run_test=*/Price*  --run_test=*/Term* --run_test=*/MarketModel* --run_test=*/Optimizers* --run_test=*/Solver*

lcov --no-external --capture --directory . --output-file ./tmp/lcov_run.info
lcov --add-tracefile ./tmp/lcov_base.info --add-tracefile ./tmp/lcov_run.info --output-file ./tmp/lcov_total.info
lcov --remove ./tmp/lcov_total.info "$PWD/Examples/*" "$PWD/test-suite/*" --output-file ./coverage/lcov.info

# Focus on modules tested by the selected unit test
lcov --remove ./coverage/lcov.info "$PWD/ql/cashflows/*" "$PWD/ql/currencies/*" "$PWD/ql/experimental/*" "$PWD/ql/indexes/*" "$PWD/ql/methods/*" "$PWD/ql/patterns/*" "$PWD/ql/processes/*" "$PWD/ql/quotes/*" "$PWD/ql/utilities/*" --output-file ./coverage/lcov_selected.info