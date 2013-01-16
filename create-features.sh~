export CHAT_CONTACT_FOR_DEVICE2="${CHAT_CONTACT_FOR_DEVICE2:-"Lake"}"
export CHAT_CONTACT_FOR_DEVICE1="${CHAT_CONTACT_FOR_DEVICE1:-"Beach"}"
for file in features/templates/*.tpl
do
	basename=$(basename "$file")
	name="${basename%.*}"
	sed 's/<CHAT_CONTACT_FOR_DEVICE2>/'"$CHAT_CONTACT_FOR_DEVICE2"'/g
s/<CHAT_CONTACT_FOR_DEVICE1>/'"$CHAT_CONTACT_FOR_DEVICE1"'/g' $file >features/$name.feature
done
