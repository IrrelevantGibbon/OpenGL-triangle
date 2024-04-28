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

	vertexShader: u32
	shader: cstring = "#version 330 core\nlayout (location = 0) in vec3 aPos;\nlayout (location = 1) in vec3 aColor;\nout vec3 ourColor;\nvoid main()\n{\n gl_Position = vec4(aPos.x, aPos.y, aPos.z, 1.0);\nourColor = aColor;\n\n}"

	vertexShader = gl.CreateShader(gl.VERTEX_SHADER)
	defer gl.DeleteShader(vertexShader)

	gl.ShaderSource(vertexShader, 1, &shader, nil)
	gl.CompileShader(vertexShader)

	if (!IsShaderCompiled(vertexShader)) {
		return
	}

	fragmentShader: u32
	fragment: cstring = "#version 330 core\n out vec4 FragColor;\nin vec3 ourColor;\nvoid main()\n{\n FragColor = vec4(ourColor, 1.0);\n}"

	fragmentShader = gl.CreateShader(gl.FRAGMENT_SHADER)
	defer gl.DeleteShader(fragmentShader)

	gl.ShaderSource(fragmentShader, 1, &fragment, nil)
	gl.CompileShader(fragmentShader)

	if (!IsShaderCompiled(fragmentShader)) {
		return
	}

	shaderProgram: u32
	shaderProgram = gl.CreateProgram()
	defer gl.DeleteProgram(shaderProgram)

	gl.AttachShader(shaderProgram, vertexShader)
	gl.AttachShader(shaderProgram, fragmentShader)
	gl.LinkProgram(shaderProgram)

	if (!IsProgramLinked(shaderProgram)) {
		return
	}

	gl.DeleteShader(vertexShader)
	gl.DeleteShader(fragmentShader)

	vertices := [18]f32 {
		0.5,
		-0.5,
		0.0,
		1.0,
		0.0,
		0.0,
		-0.5,
		-0.5,
		0.0,
		0.0,
		1.0,
		0.0,
		0.0,
		0.5,
		0.0,
		0.0,
		0.0,
		1.0,
	}

	vao: u32
	vbo: u32

	gl.GenVertexArrays(1, &vao)
	gl.BindVertexArray(vao)
	gl.GenBuffers(1, &vbo)
	gl.BindBuffer(gl.ARRAY_BUFFER, vbo)
	gl.BufferData(gl.ARRAY_BUFFER, size_of(vertices), &vertices, gl.STATIC_DRAW)


	gl.VertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, 6 * size_of(f32), uintptr(0))
	gl.EnableVertexAttribArray(0)

	gl.VertexAttribPointer(1, 3, gl.FLOAT, gl.FALSE, 6 * size_of(f32), uintptr(3 * size_of(f32)))
	gl.EnableVertexAttribArray(1)

	defer gl.DeleteBuffers(1, &vao)
	defer gl.DeleteBuffers(1, &vbo)

	for (!glfw.WindowShouldClose(window)) {
		glfw.PollEvents()
		Draw()
		gl.UseProgram(shaderProgram)
		gl.BindVertexArray(vao)
		gl.DrawArrays(gl.TRIANGLES, 0, 3)
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

IsShaderCompiled :: proc(shaderIndex: u32) -> bool {
	success: i32
	log := make([]u8, 512)
	defer delete(log)
	gl.GetShaderiv(shaderIndex, gl.COMPILE_STATUS, &success)

	if !b32(success) {
		gl.GetShaderInfoLog(shaderIndex, 512, nil, raw_data(log))
		fmt.printf("Error: Shader vertex compilation failed %s\n", log)
		return false
	}
	return true
}

IsProgramLinked :: proc(programIndex: u32) -> bool {
	success: i32
	log := make([]u8, 512)
	defer delete(log)
	gl.GetProgramiv(programIndex, gl.LINK_STATUS, &success)

	if !b32(success) {
		gl.GetShaderInfoLog(programIndex, 512, nil, raw_data(log))
		fmt.printf("Error: Program linking failed %s\n", log)
		return false
	}
	return true
}
