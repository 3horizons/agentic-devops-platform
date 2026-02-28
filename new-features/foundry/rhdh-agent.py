#!/usr/bin/env python3

"""
RHDH Agent - Foundry Agent for Red Hat Developer Hub
Uses MCP tools (Filesystem, Git, Kubernetes, GitHub) to manage RHDH deployments
"""

import logging
import json
from typing import Any, Dict
from datetime import datetime

# Configure logging
logging.basicConfig(
    level=logging.DEBUG,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)


class RDHHAgent:
    """
    Foundry Agent for RHDH with MCP tool support.
    Supports operations on RHDH configuration, deployments, and plugins.
    """

    def __init__(self):
        """Initialize the RHDH Agent"""
        self.name = "rhdh-agent"
        self.version = "1.0.0"
        self.tools = {
            "mcp-filesystem": self._init_filesystem_tool(),
            "mcp-git": self._init_git_tool(),
            "mcp-kubernetes": self._init_kubernetes_tool(),
            "mcp-github": self._init_github_tool(),
        }
        logger.info(f"Initialized {self.name} v{self.version}")

    def _init_filesystem_tool(self) -> Dict[str, Any]:
        """Initialize Filesystem MCP tool"""
        return {
            "name": "filesystem",
            "description": "Read/write files, directory traversal",
            "capabilities": [
                "read_file",
                "write_file",
                "list_directory",
                "create_directory",
                "delete_file",
                "copy_file"
            ]
        }

    def _init_git_tool(self) -> Dict[str, Any]:
        """Initialize Git MCP tool"""
        return {
            "name": "git",
            "description": "Git operations (clone, pull, diff, commit)",
            "capabilities": [
                "clone_repository",
                "pull_repository",
                "get_status",
                "get_diff",
                "commit",
                "push"
            ]
        }

    def _init_kubernetes_tool(self) -> Dict[str, Any]:
        """Initialize Kubernetes MCP tool"""
        return {
            "name": "kubernetes",
            "description": "kubectl commands, pod inspection, logs",
            "capabilities": [
                "get_pods",
                "get_services",
                "get_deployments",
                "get_logs",
                "exec",
                "describe",
                "create_resource",
                "delete_resource"
            ]
        }

    def _init_github_tool(self) -> Dict[str, Any]:
        """Initialize GitHub MCP tool"""
        return {
            "name": "github",
            "description": "Repository operations, PR creation, issues",
            "capabilities": [
                "list_repositories",
                "create_pull_request",
                "list_issues",
                "create_issue",
                "add_comment",
                "merge_pull_request"
            ]
        }

    def get_tools(self) -> Dict[str, Any]:
        """Return available MCP tools"""
        return self.tools

    def run_filesystem_operation(self, operation: str, **kwargs) -> Dict[str, Any]:
        """Execute filesystem operation"""
        logger.info(f"Executing filesystem operation: {operation}")

        operations = {
            "read_file": self._filesystem_read_file,
            "write_file": self._filesystem_write_file,
            "list_directory": self._filesystem_list_directory,
            "create_directory": self._filesystem_create_directory,
        }

        if operation not in operations:
            return {"status": "error", "message": f"Unknown operation: {operation}"}

        try:
            result = operations[operation](**kwargs)
            return {"status": "success", "data": result}
        except Exception as e:
            logger.error(f"Filesystem operation failed: {e}")
            return {"status": "error", "message": str(e)}

    def _filesystem_read_file(self, path: str) -> str:
        """Read file contents"""
        with open(path, 'r') as f:
            return f.read()

    def _filesystem_write_file(self, path: str, content: str) -> bool:
        """Write file contents"""
        with open(path, 'w') as f:
            f.write(content)
        return True

    def _filesystem_list_directory(self, path: str) -> list:
        """List directory contents"""
        import os
        return os.listdir(path)

    def _filesystem_create_directory(self, path: str) -> bool:
        """Create directory"""
        import os
        os.makedirs(path, exist_ok=True)
        return True

    def run_git_operation(self, operation: str, **kwargs) -> Dict[str, Any]:
        """Execute Git operation"""
        logger.info(f"Executing Git operation: {operation}")

        operations = {
            "clone_repository": self._git_clone,
            "pull_repository": self._git_pull,
            "get_status": self._git_status,
            "commit": self._git_commit,
        }

        if operation not in operations:
            return {"status": "error", "message": f"Unknown operation: {operation}"}

        try:
            result = operations[operation](**kwargs)
            return {"status": "success", "data": result}
        except Exception as e:
            logger.error(f"Git operation failed: {e}")
            return {"status": "error", "message": str(e)}

    def _git_clone(self, url: str, destination: str) -> str:
        """Clone Git repository"""
        import subprocess
        subprocess.run(["git", "clone", url, destination], check=True)
        return f"Cloned {url} to {destination}"

    def _git_pull(self, repository_path: str) -> str:
        """Pull repository updates"""
        import subprocess
        subprocess.run(["git", "-C", repository_path, "pull"], check=True)
        return f"Pulled updates in {repository_path}"

    def _git_status(self, repository_path: str) -> str:
        """Get repository status"""
        import subprocess
        result = subprocess.run(
            ["git", "-C", repository_path, "status"],
            capture_output=True,
            text=True,
            check=True
        )
        return result.stdout

    def _git_commit(self, repository_path: str, message: str, files: list = None) -> str:
        """Create Git commit"""
        import subprocess
        if files:
            subprocess.run(["git", "-C", repository_path, "add"] + files, check=True)
        else:
            subprocess.run(["git", "-C", repository_path, "add", "-A"], check=True)
        subprocess.run(["git", "-C", repository_path, "commit", "-m", message], check=True)
        return f"Committed: {message}"

    def run_kubernetes_operation(self, operation: str, **kwargs) -> Dict[str, Any]:
        """Execute Kubernetes operation"""
        logger.info(f"Executing Kubernetes operation: {operation}")

        operations = {
            "get_pods": self._k8s_get_pods,
            "get_logs": self._k8s_get_logs,
            "exec": self._k8s_exec,
            "describe": self._k8s_describe,
        }

        if operation not in operations:
            return {"status": "error", "message": f"Unknown operation: {operation}"}

        try:
            result = operations[operation](**kwargs)
            return {"status": "success", "data": result}
        except Exception as e:
            logger.error(f"Kubernetes operation failed: {e}")
            return {"status": "error", "message": str(e)}

    def _k8s_get_pods(self, namespace: str = "default") -> list:
        """Get pods in namespace"""
        import subprocess
        result = subprocess.run(
            ["kubectl", "get", "pods", "-n", namespace, "-o", "json"],
            capture_output=True,
            text=True,
            check=True
        )
        return json.loads(result.stdout).get("items", [])

    def _k8s_get_logs(self, pod: str, namespace: str = "default", tail: int = 50) -> str:
        """Get pod logs"""
        import subprocess
        result = subprocess.run(
            ["kubectl", "logs", "-n", namespace, pod, "--tail", str(tail)],
            capture_output=True,
            text=True,
            check=True
        )
        return result.stdout

    def _k8s_exec(self, pod: str, namespace: str, command: list) -> str:
        """Execute command in pod"""
        import subprocess
        result = subprocess.run(
            ["kubectl", "exec", "-n", namespace, pod, "--"] + command,
            capture_output=True,
            text=True,
            check=True
        )
        return result.stdout

    def _k8s_describe(self, resource_type: str, name: str, namespace: str = "default") -> str:
        """Describe resource"""
        import subprocess
        result = subprocess.run(
            ["kubectl", "describe", resource_type, "-n", namespace, name],
            capture_output=True,
            text=True,
            check=True
        )
        return result.stdout

    def run_github_operation(self, operation: str, **kwargs) -> Dict[str, Any]:
        """Execute GitHub operation"""
        logger.info(f"Executing GitHub operation: {operation}")

        operations = {
            "list_repositories": self._github_list_repos,
            "create_pull_request": self._github_create_pr,
            "list_issues": self._github_list_issues,
            "create_issue": self._github_create_issue,
        }

        if operation not in operations:
            return {"status": "error", "message": f"Unknown operation: {operation}"}

        try:
            result = operations[operation](**kwargs)
            return {"status": "success", "data": result}
        except Exception as e:
            logger.error(f"GitHub operation failed: {e}")
            return {"status": "error", "message": str(e)}

    def _github_list_repos(self, owner: str) -> list:
        """List GitHub repositories"""
        import subprocess
        result = subprocess.run(
            ["gh", "repo", "list", owner, "--json", "name,url"],
            capture_output=True,
            text=True,
            check=True
        )
        return json.loads(result.stdout)

    def _github_create_pr(self, repo: str, title: str, head: str, base: str = "main") -> Dict:
        """Create pull request"""
        import subprocess
        result = subprocess.run(
            ["gh", "pr", "create", "-R", repo, "-t", title, "-H", head, "-B", base],
            capture_output=True,
            text=True,
            check=True
        )
        return {"message": result.stdout}

    def _github_list_issues(self, repo: str) -> list:
        """List GitHub issues"""
        import subprocess
        result = subprocess.run(
            ["gh", "issue", "list", "-R", repo, "--json", "number,title,state"],
            capture_output=True,
            text=True,
            check=True
        )
        return json.loads(result.stdout)

    def _github_create_issue(self, repo: str, title: str, body: str = "") -> Dict:
        """Create GitHub issue"""
        import subprocess
        result = subprocess.run(
            ["gh", "issue", "create", "-R", repo, "-t", title, "-b", body],
            capture_output=True,
            text=True,
            check=True
        )
        return {"message": result.stdout}

    def get_status(self) -> Dict[str, Any]:
        """Get agent status"""
        return {
            "agent": self.name,
            "version": self.version,
            "status": "ready",
            "timestamp": datetime.now().isoformat(),
            "tools": list(self.tools.keys()),
            "capabilities": sum(len(t.get("capabilities", [])) for t in self.tools.values())
        }

    def execute(self, action: str, **kwargs) -> Dict[str, Any]:
        """Execute an action"""
        logger.info(f"Executing action: {action}")

        # Route to appropriate tool
        tool_name = kwargs.get("tool", "").lower()

        if tool_name.startswith("filesystem") or tool_name == "mcp-filesystem":
            return self.run_filesystem_operation(**kwargs)
        elif tool_name.startswith("git") or tool_name == "mcp-git":
            return self.run_git_operation(**kwargs)
        elif tool_name.startswith("kubernetes") or tool_name == "mcp-kubernetes":
            return self.run_kubernetes_operation(**kwargs)
        elif tool_name.startswith("github") or tool_name == "mcp-github":
            return self.run_github_operation(**kwargs)
        else:
            return {"status": "error", "message": f"Unknown tool: {tool_name}"}


def main():
    """Main entry point"""
    agent = RDHHAgent()
    status = agent.get_status()
    print(json.dumps(status, indent=2))


if __name__ == "__main__":
    main()
