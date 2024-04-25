package main

import "core:c"
import fmt "core:fmt"
import gl "vendor:OpenGL"
import glfw "vendor:glfw"

WINDOW_NAME :: "Minecraft"
WINDOW_WIDTH :: 800
WINDOW_HEIGHT :: 600


GLFW_MAJOR_VERSION :: 3
GLFW_MINOR_VERSION :: 3
OPENGL_FORWARD_COMPAT :: true

GL_MAJOR_VERSION: c.int : 4
GL_MINOR_VERSION :: 6

main :: proc() {
	if !glfw.Init() {
		fmt.print("Failed to initialize GLFW")
		return
	}
	defer glfw.Terminate()

	SetContext()

	window := glfw.CreateWindow(WINDOW_WIDTH, WINDOW_HEIGHT, WINDOW_NAME, nil, nil)
	defer glfw.DestroyWindow(window)

	if window == nil {
		fmt.print("Failed to create GLFW window\n")
		return
	}
	glfw.MakeContextCurrent(window)

	glfw.SwapInterval(1)

	glfw.SetKeyCallback(window, KeyCallback)

	glfw.SetFramebufferSizeCallback(window, SizeCallback)

	gl.load_up_to(int(GL_MAJOR_VERSION), GL_MINOR_VERSION, glfw.gl_set_proc_address)

	gl.Viewport(0, 0, WINDOW_WIDTH, WINDOW_HEIGHT)


	for (!glfw.WindowShouldClose(window)) {
		glfw.PollEvents()
		Draw()
		glfw.SwapBuffers((window))
	}

}

Draw :: proc() {
	gl.ClearColor(0.2, 0.3, 0.3, 1.0)
	gl.Clear(gl.COLOR_BUFFER_BIT)
}

KeyCallback :: proc "c" (window: glfw.WindowHandle, key, scancode, action, mods: i32) {
	if key == glfw.KEY_ESCAPE {
		glfw.SetWindowShouldClose(window, true)
	}
}

SizeCallback :: proc "c" (window: glfw.WindowHandle, width: i32, height: i32) {
	gl.Viewport(0, 0, width, height)
}

SetContext :: proc() {
	glfw.WindowHint(glfw.CONTEXT_VERSION_MAJOR, GLFW_MAJOR_VERSION)
	glfw.WindowHint(glfw.CONTEXT_VERSION_MINOR, GLFW_MINOR_VERSION)
	glfw.WindowHint(glfw.OPENGL_PROFILE, glfw.OPENGL_CORE_PROFILE)
	glfw.WindowHint(glfw.OPENGL_FORWARD_COMPAT, OPENGL_FORWARD_COMPAT)
}
