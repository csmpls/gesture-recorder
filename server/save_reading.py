import json 
from os import path
from os import makedirs
from os import listdir 
from write_object_to_json_file import write_object_to_json_file

'''recursively create directories ad needed
'''
def mkdir_p(path):
    try:
        makedirs(path)
    except:
        pass


'''' next numerical filename in path (path)

~ also works with directories~

goes to "path", finds the file with the highest numerical value filename
(excluding file extensions) and returns that number plus one

for example: given a directory:

numerical_dir/ 
	1.json
	2.json 
	3.json
	6.json
	not-a-numerical-file.json
	also-not-numerical

>> next_numerical_filename_in_path('numerical_dir/')
>> 8 

'''

def next_numerical_filename_in_path(path):

	def is_number (s):
		try:
			float(s)
			return True
		except ValueError:
			return False

	def filename_without_extension (filename):
		return filename.split('.')[0]

	# returns the numbers of 
	# ONLY those directories that have numberical filenames
	def numbers_from_numerical_filenames (filenames):
		for fn in filenames:
			fn_wo_ext = filename_without_extension(fn)	
			if is_number(fn_wo_ext): yield fn_wo_ext

	try:
		return int(max(numbers_from_numerical_filenames(listdir(path))))+1
	except:
		return 0

''' WRITE OBJECT TO JSON FILE

takes a python object and a path
turns that object into json and writes it to file
'''

def write_object_to_json_file(object, path):
    with open(path, 'w') as f:
        f.write(json.dumps(object))


''' GET_TRIAL_PATH

trial path is id/subject/position/task/[trial#]
where trial# and slice# are sequential nubmers
everything is created recursively as-needed 
'''

def get_trial_path (id, position, task):
	base_path = path.join('data', id, position, task)
	trial_path = path.join(base_path,
		str(next_numerical_filename_in_path(base_path)))
	# create the trial path if it doesn't exist
	mkdir_p(trial_path)
	return trial_path


''' SAVE_READING 
save a reading (python object) in trial_path/slice#.json
where slice# is a sequential number
'''	

def save_reading (reading, trial_path):
	write_object_to_json_file(	
		reading,
		path.join(trial_path, 
			str(next_numerical_filename_in_path(trial_path)) + '.json'))
