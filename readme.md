# 👜 Tote

Tote is the nichest, weirdest piece of software I've ever written.  It's an Odin program designed to modify Odin source code, specifically to manually pack or unpack constant strings into or out of `#load` compiler directives.

Note that `tote` is a quick and sketchy piece of software: it has not been extensively tested and you should check any files in *before* running `tote` on them.

## Example

Given an Odin `source.odin` file like this —

```odin
// @tote shader.vert
SHADER_VERT :: #load("shader.vert", string)

// @tote shader.frag
SHADER_FRAG :: #load("shader.frag", string)
```

— running `tote source.odin` would directly import the contents of `shader.vert` and `shader.frag` into raw strings and delete the two files, overwriting `source.odin` with —

```odin
// @tote shader.vert
SHADER_VERT :: `#version 460 core

layout (location = 0) in vec4 vertex;

void main() {
	gl_Position = vertex;
}`

// @tote shader.frag
SHADER_FRAG :: `#version 460 core

out vec4 color;

void main() {
	color = vec4(1, 1, 1, 1);
}`
```

Running `tote source.odin` again will reverse the process and restore the shader files.  The process is transparent to the Odin compiler, meaning the codebase will correctly compile in either state; this is purely a tool to aid code comprehension.

## Usage

```sh
tote some_file.odin
```

## Compilation

```sh
odin build tote.odin -file -o:speed
```

## Requirements

It should be clear that these **exact** two-line layouts are required for `tote` to work, and you should probably not mix them in a single file[^1].

```odin
// @tote filename.txt
CONSTANT HANDLE :: `raw string in backticks`

// @tote filename.txt
CONSTANT HANDLE :: #load("filename.txt", string)
```

## Why?

I use the `#load` directive in Odin a lot.  Almost all of the software I write in Odin bundles bundle at least some core resources with it.  However, sometimes it makes more sense to embed strings directly in code instead, and sometimes it makes sense to do *both at once*.

I prefer to write shader code in a single file; complex shaders are easier to write and edit in the same file with all their shared namespaces.  However, I prefer to check resources as important as shaders in as separate files for clarity in a 'codebase context' and `#load` them.  *Reading* shaders is a lot easier when they're not embedded.

`tote` lets me have my cake and eat it.

[^1]: Technically nothing bad will happen, it'll just invert which ones are files and which are strings, which seems silly.
