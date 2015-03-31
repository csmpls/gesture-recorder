import json 
from os import path
from os import makedirs
from os import listdir 


''' takes a dict with unicode string objects 
	returns a dict with strings
'''
def decode_dict(data):
    rv = {}
    for key, value in data.iteritems():
        if isinstance(key, unicode):
            key = key.encode('utf-8')
        if isinstance(value, unicode):
            value = value.encode('utf-8')
        elif isinstance(value, list):
            value = _decode_list(value)
        elif isinstance(value, dict):
            value = _decode_dict(value)
        rv[key] = value
    return rv

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
		numbers = []
		for fn in filenames:
			fn_wo_ext = filename_without_extension(fn)	
			if is_number(fn_wo_ext): yield int(fn_wo_ext)

	try:
		return int(max(numbers_from_numerical_filenames(listdir(path))))+1
	except:
		return 0

''' WRITE OBJECT TO JSON FILE

takes a json object and a path
writes it to a json file
'''

def write_object_to_json_file(object, path):
	print 'printing', path
	with open(path, 'w') as f:
		f.write(str(object))
	return 0

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
save a reading (json object) in trial_path/slice#.json
where slice# is a sequential number
'''	

def save_reading (reading, trial_path):
	write_object_to_json_file(	
		reading,
		path.join(trial_path, 
			str(next_numerical_filename_in_path(trial_path)) + '.json'))
	return 0