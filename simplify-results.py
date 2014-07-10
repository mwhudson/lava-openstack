import csv
import re
import sys

result_map = {
    'success': 'pass',
    'failure': 'fail',
    'error': 'fail',
    'skip': 'skip',
    'xfail': 'pass' #?
    }

def clean_test_id(test_id):
    if '[' in test_id:
        test_id = test_id[:test_id.index('[')]
    return re.sub('[^-0-9A-Za-z_.]', '-', test_id)

seen_tests = set()

all_tests = set()
tests_by_class = {}

for l in open(sys.argv[2]):
    test_id = clean_test_id(l.strip())
    all_tests.add(test_id)
    test_class_id, test_case_id = test_id.rsplit('.', 1)
    tests_by_class.setdefault(test_class_id, []).append(test_id)


SETUP_PREFIX = 'setUpClass--'
RESULT_TMPL = "TEST@%s@ RESULT@%s@"

for d in csv.DictReader(open(sys.argv[1])):
    test_id = clean_test_id(d['test'])
    if test_id.startswith('setUpClass--') and d['status'] == 'skip':
        test_class = test_id[len(SETUP_PREFIX):-1]
        for test_id in tests_by_class[test_class]:
            print RESULT_TMPL % (test_id, 'skip')
            seen_tests.add(test_id)
    seen_tests.add(test_id)
    result = result_map.get(d.get('status', 'unknown'))
    print RESULT_TMPL % (test_id, result)


for test_id in all_tests - seen_tests:
    print RESULT_TMPL % (test_id, 'unknown')
