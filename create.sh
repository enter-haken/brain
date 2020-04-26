#!/bin/bash
echo "\`\`\`"
echo "id: $(cat /proc/sys/kernel/random/uuid)"
echo "title: $1"
echo "\`\`\`"
