import sys

accessedFiles = {}
for trace_file in sys.argv[1:]:
	with open(trace_file, "r") as f:
		for line in f:
			line = line.split('\t')
			if line[0] in ['rename', 'unlink', 'link', 'symlink']:
				pass
			else:
				assert len(line) == 4
				filename = line[0]
				op = line[1]
				if filename not in accessedFiles:
					accessedFiles[filename] = []
				if op not in accessedFiles[filename]:
					accessedFiles[filename].append(op)


for i in accessedFiles:
	print i #, "\t", accessedFiles[i]