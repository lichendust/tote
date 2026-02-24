package tote

import "core:os"
import "core:fmt"
import "core:strings"
import "core:unicode"
import "core:unicode/utf8"
import "core:path/filepath"

main :: proc() {
	args := os.args[1:]
	if len(args) == 0 {
		return
	}

	blob, success := os.read_entire_file(args[0])
	if !success {
		fmt.eprintln("usage: tote [source.odin]")
		return
	}

	b: strings.Builder
	strings.builder_init(&b, 0, len(blob))

	text := transmute(string) blob
	cutoff: int
	last_cutoff: int

	dir := filepath.dir(args[0])

	outer_loop: for {
		if cutoff >= len(text) {
			break
		}

		at_index := strings.index(text[cutoff:], "@tote")
		if at_index > -1 {
			cutoff += at_index + 5

			index := extract_to_newline(text[cutoff:])
			file_name := strings.trim_space(text[cutoff:cutoff+index])

			cutoff += index + 1

			index = strings.index_rune(text[cutoff:], '`')
			if index > -1 {
				cutoff += index + 1

				strings.write_string(&b, text[last_cutoff:cutoff-1])
				strings.write_string(&b, "#load(\"")
				strings.write_string(&b, file_name)
				strings.write_string(&b, "\", string)")

				end_index := strings.index_rune(text[cutoff:], '`')

				file_path   := filepath.join({dir, file_name})
				shader_text := text[cutoff:cutoff + end_index]

				os.write_entire_file(file_path, transmute([]byte) shader_text)

				cutoff += end_index + 1
				last_cutoff = cutoff
				continue
			}

			index = strings.index_rune(text[cutoff:], '#')
			if index > -1 {
				cutoff += index

				file_path := filepath.join({dir, file_name})

				strings.write_string(&b, text[last_cutoff:cutoff])
				blob, success := os.read_entire_file(file_path)
				if !success {
					fmt.println()
					continue
				}

				os.remove(file_path)

				strings.write_rune(&b, '`')
				strings.write_string(&b, transmute(string) blob)
				strings.write_rune(&b, '`')
				strings.write_rune(&b, '\n')

				cutoff += 1

				end_index := strings.index_rune(text[cutoff:], '\n')

				cutoff += end_index + 1
				last_cutoff = cutoff
				continue
			}
		} else {
			strings.write_string(&b, text[last_cutoff:cutoff])
			break
		}
	}

	os.write_entire_file(args[0], transmute([]byte) strings.to_string(b))
}

extract_ident :: proc(text: string) -> int {
	for c, index in text {
		if unicode.is_space(c) {
			return index
		}
	}
	return len(text)
}

extract_to_newline :: proc(text: string) -> int {
	for c, index in text {
		if c == '\n' {
			return index
		}
	}
	return len(text)
}
