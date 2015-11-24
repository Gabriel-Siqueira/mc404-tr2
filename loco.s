.global beg
	
.text

beg:
	mov r7, #19
	mov r0, #100
	mov r1, #100
	svc 0
l: b l
