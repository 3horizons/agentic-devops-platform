import re

with open("deploy/helm/rhdh/values-aks-dev.yaml", "r") as f:
    content = f.read()

content = re.sub(
    r'- package: \./dynamic-plugins/dist/backstage-community-plugin-rbac\n\s+disabled: false',
    r'- package: ./dynamic-plugins/dist/backstage-community-plugin-rbac\n        disabled: true',
    content
)

with open("deploy/helm/rhdh/values-aks-dev.yaml", "w") as f:
    f.write(content)
