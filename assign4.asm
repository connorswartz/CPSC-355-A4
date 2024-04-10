// File: assign4.asm
// Author: Connor Swartz
// Date: March 16, 2022
//
// Description:
// Create a program that declares and uses structs in order to create boxes, compare boxes, move boxes, and change box sizes.
//

define(FALSE, 0)
define(TRUE, 1)
define(nb_r, w0)
define(first_cmp, w6)
define(second_cmp, w7)
define(b_r, x19)
define(move_c, w20)
define(expand_w, w21)
define(expand_h, w22)
define(result, w26)
define(first_box, x27)
define(second_box, x28)

base_size = 16										// Define the size of the base on the stack 

x_off = 0										// Define the offset of x
y_off = 4										// Define the offset of y
point_size = 8										// Define the size of point struct (x size + y size)

width_off = 0										// Define the offset of width
height_off = 4										// Define the offset of height
dim_size = 8										// Define the size of dimension struct (width size + height size)

origin_off = 0										// Define the offset of point origin struct
dim_size_off = 8									// Define the offset of dimension size struct
area_off = 16										// Define the offset of area
box_size = 20										// Define the size of box struct (point size + dim size + area size)

first_box_off = 16									// Define the offset of the first box
second_box_off = 36									// Define the offset of the second box

box_alloc = -(base_size + box_size) & -16						// Create variable for box stack allocation
box_dealloc = -box_alloc								// Create variable for box stack deallocation

main_alloc = -(base_size + (box_size * 2)) & -16					// Create variable for main stack allocation
main_dealloc = -main_alloc								// Create variable for main stack deallocation

equal_alloc = main_alloc								// Create variable for equal stack allocation
equal_dealloc = main_dealloc								// Create variable for equal stack deallocation

first:		.string "first"								// Store string in memory and create label for future
second:		.string "second"							// Store string in memory and create label for future

p1:		.string "Initial box values:\n"						// Store string in memory and create label for future
p2:		.string "Box %s origin = (%d, %d)  width = %d  height = %d  area = %d\n"	// Store string in memory and create label for future
p3:		.string "\nChanged box values:\n"					// Store string in memory and create label for future

fp		.req	x29
lr		.req	x30

		.balign 4								// Ensures the next instruction address is divisible by 4
											// (i.e. 4-byte aligned to the word length of the machine)
		.global main								// Make "main" visible to the linker

newBox:
		stp	fp, lr, [sp, box_alloc]!					// Save frame pointer (FP) and link register (LR) to the stack 
		mov	fp, sp								// Set FP to the top of the stack

		str	wzr, [b_r, origin_off + x_off]					// b.origin.x = 0
		str	wzr, [b_r, origin_off + y_off]					// b.origin.y = 0

		mov	nb_r, 1								// Set nb_r to 1

		str	nb_r, [b_r, dim_size_off + width_off]				// b.size.width = 1
		str	nb_r, [b_r, dim_size_off + height_off]				// b.size.height = 1

		mul	nb_r, nb_r, nb_r						// Multiply nb_r by nb_r register and store in nb_r (nb_r = 1 * 1)
		
		str	nb_r, [b_r, area_off]						// b.area = nb_r (1)

		ldp	fp, lr, [sp], box_dealloc					// Clean lines and restore the stack 
		ret									// Return

move:
		stp	fp, lr, [sp, box_alloc]!					// Save the frame pointer (FP) and link register (LR) to the stack
		mov	fp, sp								// Set FP to the top of the stack

		ldr	move_c, [b_r, origin_off + x_off]				// Set move_c to b->origin.x
		add	move_c, move_c, w2						// Add w2 to move_c and store in move_c
		str	move_c, [b_r, origin_off + x_off]				// Set b->origin.x to move_c (b->origin.x += deltaX)

		ldr	move_c, [b_r, origin_off + y_off]				// Set move_c register to b->origin.y 
		add	move_c, move_c, w3						// Add w3 to move_c and store in move_c
		str	move_c, [b_r, origin_off + y_off]				// Set b->origin.y to move_c (b->origin.y += deltaY)

		ldp	fp, lr, [sp], box_dealloc					// Clean lines and restore the stack
		ret									// Return

expand:
		stp	fp, lr, [sp, box_alloc]!					// Save the frame pointer (FP) and linke register (LR) to the stack
		mov	fp, sp								// Save FP to the top of the stack

		ldr	expand_w, [b_r, dim_size_off + width_off]			// Set expand_w to b->size.width
		mul	expand_w, expand_w, w2						// Multiply w2 by expand_w and store in expand_w
		str	expand_w, [b_r, dim_size_off + width_off]			// Set b->size.width to expand_w (b->size.width *= w2)

		ldr	expand_h, [b_r, dim_size_off + height_off]			// Set expand_h to b->size.height
		mul	expand_h, expand_h, w2						// Multiply w2 by expand_h and store in expand_h
		str	expand_h, [b_r, dim_size_off + height_off]			// Set b->size.height to expand_h (b->size.height *= w2)

		mul	expand_w, expand_w, expand_h					// Multiply expand_h by expand_w and store in expand_w
		str	expand_w, [b_r, area_off]					// Set b->area to expand_w (b->area = width * height)

		ldp	fp, lr, [sp], box_dealloc					// Clean lines and restore the stack
		ret									// Return

printBox:
		stp	fp, lr, [sp, box_alloc]!					// Save frame pointer (FP) and link register (LR) to the stack
		mov	fp, sp								// Save FP to the top of the stack

		ldr	w0, =p2								// Load address of p2 into w0
		ldr	w2, [b_r, origin_off + x_off]					// Load point x into w2
		ldr	w3, [b_r, origin_off + y_off]					// Load point y into w3
		ldr	w4, [b_r, dim_size_off + width_off]				// Load box width into w4
		ldr	w5, [b_r, dim_size_off + height_off]				// Load box height into w5
		ldr	w6, [b_r, area_off]						// Load box area into w6
		bl	printf								// Call print (w0-w6)

		ldp	fp, lr, [sp], box_dealloc					// Clean lines and restore the stack
		ret									// Return
equal:
		stp	fp, lr, [sp, equal_alloc]!					// Save the frame pointer (FP) and link register (LR) to the stack
		mov	fp, sp								// Save FP to the top of the stack

		mov	result, FALSE							// Set result to FALSE (0)

		ldr	first_cmp, [first_box, origin_off + x_off]			// Set first_cmp to b1->origin.x
		ldr	second_cmp, [second_box, origin_off + x_off]			// Set second_cmp to b2->origin.x
		cmp	first_cmp, second_cmp						// Compare first_cmp to second_cmp (if (b1->origin.x == b2->origin.x))
		b.ne	equal_end							// If first_cmp and second_cmp are not equal, branch to equal_end

		ldr	first_cmp, [first_box, origin_off + y_off]			// Set first_cmp to b1->origin.y
		ldr	second_cmp, [second_box, origin_off + y_off]			// Set second_cmp to b2->origin.y 
		cmp	first_cmp, second_cmp						// Compare first_cmp to second_cmp (if (b1->origin.y == b2->origin.y))
		b.ne	equal_end							// If first_cmp and second_cmp are not equal, branch to equal_end

		ldr	first_cmp, [first_box, dim_size_off + width_off]		// Set first_cmp to b1->size.width
		ldr	second_cmp, [second_box, dim_size_off + width_off]		// Set second_cmp to b2->size.width
		cmp	first_cmp, second_cmp						// Compare first to second (if (b1->size.width == b2->size.width))
		b.ne	equal_end							// If first_cmp and second_cmp are not equal, branch to equal_end

		ldr	first_cmp, [first_box, dim_size_off + height_off]		// Set first_cmp to b1->size.height
		ldr	second_cmp, [second_box, dim_size_off + height_off]		// Set second_cmp to b2->size.height
		cmp	first_cmp, second_cmp						// Compare first to second (if (b1->size.height == b2->size.height))
		b.ne	equal_end							// If first_cmp and secon_cmp are not equal, branch to equal_end

		mov	result, TRUE							// Set result to TRUE (1)

equal_end:	
		ldp	fp, lr, [sp], equal_dealloc					// Clean lines and restore stack
		ret									// Return

main:
		stp	fp, lr, [sp, main_alloc]!					// Save the frame pointer (FP) and link register (LP) to the stack
		mov	fp, sp								// Save FP to the top of the stack

		mov	b_r, fp								// Set b_r to fp

		ldr	w0, =p1								// Load p1 into w0 register
		bl	printf								// Call print (w0)

		add	b_r, fp, first_box_off						// Set b_r to fp + first_box_off (b_r = offset for first box)
		bl	newBox								// Branch to newBox

		add	b_r, fp, second_box_off						// Set b_r to fp + second_box_off (b_r = offset for second box)
		bl	newBox								// Branch to newBox

		add	b_r, fp, first_box_off						// Set b_r to fp + first_box_off (b_r = offset for first box)
		ldr	w1, =first							// Load first into w1 register
		bl	printBox							// Branch to printBox

		add	b_r, fp, second_box_off						// Set b_r to fp + second_box_off (b_r = offset for second box)
		ldr	w1, =second							// Laod second into w1 register
		bl	printBox							// Branch to printBox

		ldr	w0, =p3								// Load p3 into w0 register
		bl	printf								// Call print (w0)

		add	first_box, fp, first_box_off					// Set first_box to offset for first box
		add	second_box, fp, second_box_off					// Set second_box to offset for second box
		bl	equal								// Branch to equal

		cmp	result, FALSE							// Compare result to FALSE (0)
		b.eq	main_end							// If result is equal to FALSE, branch to main_end
	
		mov	w2, -5								// Set w2 register to -5
		mov	w3, 7								// Set w3 register to 7
		add	b_r, fp, first_box_off						// Set b_r to offset of first box
		bl	move								// Branch to move

		mov	w2, 3								// Set w2 register to 3
		add	b_r, fp, second_box_off						// Set b_r to offset of second box
		bl	expand								// Branch to expand

main_end:	
		add	b_r, fp, first_box_off						// Set b_r to offset of first box
		ldr	w1, =first							// Load first into w1 register
		bl	printBox							// Branch to printBox

		add	b_r, fp, second_box_off						// Set b_r to offset of second box
		ldr	w1, =second							// Load second into w1 register
		bl	printBox							// Branch to printBox

		ldp	fp, lr, [sp], main_dealloc					// Clean lines and restore stack
		mov	x0, 0								// Set return code to 0 (no errors)
		ret									// Return to OS
