find moon -iname "*.moon" -exec moonc -t ./lua/ {} \; && mv lua/moon/* lua/ && rm -rf lua/moon
