package main

import "core:c"
import fmt "core:fmt"
import "vendor:ENet"
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


	vertices := [9]f32{-0.5, -0.5, 0.0, 0.5, -0.5, 0.0, 0.0, 0.5, 0.0}

	vbo: u32

	gl.GenBuffers(1, &vbo)
	gl.BindBuffer(gl.ARRAY_BUFFER, vbo)
	gl.BufferData(gl.ARRAY_BUFFER, size_of(vertices), &vertices, gl.STATIC_DRAW)
	defer gl.DeleteBuffers(1, &vbo)

	vertexShader: u32
	shader: cstring = "#version 330 core\n layout (location = 0) in vec3 aPos;\nvoid main()\n{\n gl_Position = vec4(aPos.x, aPos.y, aPos.z, 1.0);\n}"

	vertexShader = gl.CreateShader(gl.VERTEX_SHADER)
	defer gl.DeleteShader(vertexShader)

	gl.ShaderSource(vertexShader, 1, &shader, nil)
	gl.CompileShader(vertexShader)

	if (!IsShaderCompiled(vertexShader, gl.COMPILE_STATUS)) {
		return
	}

	fragmentShader: u32
	fragment: cstring = "#version 330 core\n out vec4 FragColor;\n\nvoid main()\n{\n FragColor = vec4(1.0f, 0.5f, 0.2f, 1.0f);\n}"

	fragmentShader = gl.CreateShader(gl.FRAGMENT_SHADER)
	defer gl.DeleteShader(fragmentShader)

	gl.ShaderSource(fragmentShader, 1, &fragment, nil)
	gl.CompileShader(fragmentShader)

	if (!IsShaderCompiled(fragmentShader, gl.COMPILE_STATUS)) {
		return
	}

	shaderProgramn: u32
	shaderProgramn = gl.CreateProgram()
	defer gl.DeleteProgram(shaderProgramn)

	gl.AttachShader(shaderProgramn, vertexShader)
	gl.AttachShader(shaderProgramn, fragmentShader)
	gl.LinkProgram(shaderProgramn)

	if (!IsShaderCompiled(shaderProgramn, gl.LINK_STATUS)) {
		return
	}

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

IsShaderCompiled :: proc(shaderIndex: u32, flag: u32) -> bool {
	success: i32
	log := make([]u8, 512)
	defer delete(log)
	gl.GetShaderiv(shaderIndex, flag, &success)
	if !b32(success) {
		gl.GetShaderInfoLog(shaderIndex, 512, nil, raw_data(log))
		fmt.printf("Error: Shader vertex compilation failed %s\n", log)
		return false
	}
	return true
}
