import os

output_file = "all_files.txt"

with open(output_file, "w", encoding="utf-8") as out:
    for root, dirs, files in os.walk("."):
        for filename in files:
            file_path = os.path.join(root, filename)
            try:
                with open(file_path, "r", encoding="utf-8") as f:
                    content = f.read()
                out.write(f"{file_path} ->\n")
                out.write(content)
                out.write("\n\n")  # spacing between files
            except Exception as e:
                out.write(f"{file_path} ->\n[Error reading file: {e}]\n\n")

print(f"✅ All file contents have been written to '{output_file}'.")