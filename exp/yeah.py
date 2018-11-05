
def main():
	nodes 	  = [ osd0, osd1, osd2 ]
	goodtask  = [ "write obj1", "read obj1"]
	errops    = [ "corrupt-zero", "corrupt-junk", "corrupt-bit", 
				  "eio-read", "eio-write", "enospc-space"];

	##  Part 1: Run good tasks and retrieve Trace File
	init_cluster(nodes)			 # Initialize Cluster
	init_state = snapshot(nodes) # Take a snapshot of the initial state
	trace_files = trace(nodes, goodtask)

	##  Part 2: Injection Faults and analyze logs	
	allLogFiles = []
	for (node, traceFile) in trace_files:
		for op, block in all_operations(traceFile):
			for errop in errops:
				inject(errop, block)
				logFiles = run(goodtask)
				analyze(logFiles)





##  Part 2: Inject Faults
def inject():



##  Part 1: File Trace
def trace(nodes, goodtask):

	# Mount errfs
	mount_errfs(nodes)

	# Run tasks and obtain the result of the operation
	#   - Write some data such as "aaa...aaa" on the osd.
	#   - Check if the data is as expected
	results = run_tasks(goodtask)
	if result != RESULT_GOOD: return None
		
	# Unmount errfs
	unmount_errfs(nodes)

	# Retrieve Trace Files 
	trace_files = retrieve_trace_files(nodes)
