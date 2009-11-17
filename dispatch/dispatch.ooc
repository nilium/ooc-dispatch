use dispatch
include dispatch/dispatch
import os/Time

TimeSpec: cover from struct timespec {
	seconds: extern(tv_sec) TimeT
	nanoseconds: extern(tv_nsec) Long
}

DispatchFunction: cover from dispatch_function_t
DispatchQueueAttr: cover from dispatch_queue_attr_t

DispatchTime: cover from dispatch_time_t {
	new: static extern(dispatch_time) func(base: DispatchTime, offset: Int64) -> This
	new: static extern(dispatch_walltime) func ~relative(base: TimeSpec*, offset: Int64)
	
	now: static extern(DISPATCH_TIME_NOW) const This
	forever: static extern(DISPATCH_TIME_FOREVER) const This
}

DispatchObject: cover from dispatch_object_t {
	suspend: extern(dispatch_suspend) func
	resume: extern(dispatch_resume) func
	getContext: extern(dispatch_get_context) func -> Pointer
	setContext: extern(dispatch_set_context) func(Pointer)
	setFinalizer: extern(dispatch_set_finalizer_f) func
	
	// only applies to queues and sources
	setTargetQueue: extern(dispatch_set_target_queue) func(DispatchQueue)
	
	// you probably shouldn't use these in your own code
	retain: extern(dispatch_retain) func
	release: extern(dispatch_release) func
	
	destroy: func {
		release()
	}
}

dispatch_apply_f: extern func(iterations: SizeT, DispatchQueue, context: Pointer, DispatchFunction)

DispatchQueue: cover from dispatch_queue_t extends DispatchObject {
	PRIORITY_HIGH: static extern(DISPATCH_QUEUE_PRIORITY_HIGH) const Long
	PRIORITY_DEFAULT: static extern(DISPATCH_QUEUE_PRIORITY_DEFAULT) const Long
	PRIORITY_LOW: static extern(DISPATCH_QUEUE_PRIORITY_LOW) const Long
	
	// attributes must be null
	new: static extern(dispatch_queue_create) func(label: String, DispatchQueueAttr) -> This
	
	currentQueue: static extern(dispatch_get_current_queue) func -> This
	globalQueue: static extern(dispatch_get_global_queue) func(priority: Long, flags: ULong) -> This
	mainQueue: static extern(dispatch_get_main_queue) func -> This
	
	main: static extern(dispatch_main) func -> This
	
	label: extern(dispatch_queue_get_label) func -> String
	
	async: extern(dispatch_async_f) func(context:Pointer, DispatchFunction)
	sync: extern(dispatch_sync_f) func(context:Pointer, DispatchFunction)
	
	apply: func(iterations: SizeT, context:Pointer, fn: Func(Pointer, SizeT)) {
		dispatch_apply_f(iterations, this, context, fn)
	}
}

DispatchGroup: cover from dispatch_group_t extends DispatchObject {
	new: static extern(dispatch_group_create) func -> This
	
	enter: extern(dispatch_group_enter) func
	leave: extern(dispatch_group_leave) func
	wait: extern(dispatch_group_wait) func(timeout: DispatchTime) -> Long
	notify: extern(dispatch_group_notify_f) func(DispatchQueue, DispatchFunction)
	
	async: extern(dispatch_group_async_f) func(DispatchQueue, context:Pointer, DispatchFunction)
	sync: extern(dispatch_group_sync_f) func(DispatchQueue, context:Pointer, DispatchFunction)
}

DispatchOnce: cover from dispatch_once_t {
	run: extern(dispatch_once_f) func(context: Pointer, DispatchFunction)
}

DispatchSemaphore: cover from dispatch_semaphore_t extends DispatchObject {
	new: static extern(dispatch_semaphore_create) func(count: Long) -> This
	
	signal: extern(dispatch_semaphore_signal) func -> Long
	wait: extern(dispatch_semaphore_wait) func(timeout: DispatchTime) -> Long
}

DispatchSourceType: cover from dispatch_source_type_t {
	DATA_ADD: static extern(DISPATCH_SOURCE_TYPE_DATA_ADD) const This
	DATA_OR: static extern(DISPATCH_SOURCE_TYPE_DATA_OR) const This
	MACH_SEND: static extern(DISPATCH_SOURCE_TYPE_MACH_SEND) const This
	MACH_RECV: static extern(DISPATCH_SOURCE_TYPE_MACH_RECV) const This
	PROC: static extern(DISPATCH_SOURCE_TYPE_PROC) const This
	READ: static extern(DISPATCH_SOURCE_TYPE_READ) const This
	SIGNAL: static extern(DISPATCH_SOURCE_TYPE_SIGNAL) const This
	TIMER: static extern(DISPATCH_SOURCE_TYPE_TIMER) const This
	VNODE: static extern(DISPATCH_SOURCE_TYPE_VNODE) const This
	WRITE: static extern(DISPATCH_SOURCE_TYPE_WRITE) const This
}

DispatchSource: cover from dispatch_source_t extends DispatchObject {
	new: static extern(dispatch_source_create) func(DispatchSourceType, handle: Pointer, mask: ULong, DispatchQueue)
	
	setEventHandler: extern(dispatch_source_set_event_handler_f) func(DispatchFunction)
	setCancelHandler: extern(dispatch_source_set_cancel_handler_f) func(DispatchFunction)
	
	cancel: extern(dispatch_source_cancel) func
	testCancel: extern(dispatch_source_testcancel) func
	
	handle: extern(dispatch_source_get_handle) func -> Pointer
	mask: extern(dispatch_source_get_mask) func -> ULong
	data: extern(dispatch_source_get_data) func -> ULong
	
	mergeData: extern(dispatch_source_merge_data) func(data: ULong)
	
	setTimer: extern(dispatch_source_set_timer) func(start: DispatchTime, interal, leeway: UInt64)
}
