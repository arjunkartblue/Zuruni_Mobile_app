import os

lib_dir = '/Users/mac/Desktop/Zuruni_Mobile_app/lib'

replacements = {
    'MainAxisAlignment.between': 'MainAxisAlignment.spaceBetween',
    'placeholder:': 'hintText:',
    'Icons.calendar_add_on_outlined': 'Icons.calendar_today_outlined',
    'Icons.gate': 'Icons.vpn_key_outlined'
}

for root, dirs, files in os.walk(lib_dir):
    for file in files:
        if file.endswith('.dart'):
            filepath = os.path.join(root, file)
            with open(filepath, 'r') as f:
                content = f.read()
            
            modified = False
            for old, new in replacements.items():
                if old in content:
                    content = content.replace(old, new)
                    modified = True
            
            if modified:
                print(f"Modifying {file}...")
                with open(filepath, 'w') as f:
                    f.write(content)

print("Done fixing errors!")
