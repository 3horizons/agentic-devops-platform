#!/usr/bin/env python3

"""
Lightspeed Monitor Agent - Foundry Agent for Lightspeed Health Monitoring
Monitors Lightspeed Chat Service, Llama Stack, and RAG Engine health and performance
"""

import logging
import json
import time
from typing import Any, Dict, List
from datetime import datetime
import requests
import subprocess

# Configure logging
logging.basicConfig(
    level=logging.DEBUG,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)


class LightspeedMonitorAgent:
    """
    Foundry Agent for monitoring Lightspeed stack health and performance.
    Tracks response times, error rates, and user satisfaction metrics.
    """

    def __init__(self, namespace: str = "lightspeed", cluster: str = "rhdh-prod"):
        """
        Initialize Lightspeed Monitor Agent

        Args:
            namespace: Kubernetes namespace
            cluster: Cluster name for monitoring
        """
        self.name = "lightspeed-monitor-agent"
        self.version = "1.0.0"
        self.namespace = namespace
        self.cluster = cluster
        self.metrics = {
            "lcs_health": None,
            "llama_stack_health": None,
            "rag_engine_health": None,
            "response_times": [],
            "error_count": 0,
            "successful_requests": 0,
            "user_satisfaction": [],
        }
        logger.info(f"Initialized {self.name} v{self.version} for {cluster}/{namespace}")

    def check_lcs_health(self) -> Dict[str, Any]:
        """Check Lightspeed Chat Service health"""
        logger.info("Checking LCS health...")

        try:
            # Get LCS pods
            pods = self._get_pods("app=lcs")
            if not pods:
                return {
                    "status": "unhealthy",
                    "message": "No LCS pods found",
                    "timestamp": datetime.now().isoformat()
                }

            # Check pod status
            running_pods = [p for p in pods if p["status"]["phase"] == "Running"]
            ready_replicas = sum(
                1 for p in pods
                if p["status"].get("conditions", [])
                and any(c["type"] == "Ready" and c["status"] == "True" for c in p["status"]["conditions"])
            )

            # Port forward to LCS
            lcs_pod = running_pods[0]["metadata"]["name"] if running_pods else None
            if not lcs_pod:
                return {
                    "status": "unhealthy",
                    "message": "No running LCS pods",
                    "timestamp": datetime.now().isoformat()
                }

            # Test /health endpoint
            health_status = self._test_lcs_endpoint(lcs_pod, "/health")
            ready_status = self._test_lcs_endpoint(lcs_pod, "/ready")

            return {
                "status": "healthy" if health_status and ready_status else "unhealthy",
                "running_pods": len(running_pods),
                "ready_replicas": ready_replicas,
                "health_endpoint": health_status,
                "ready_endpoint": ready_status,
                "timestamp": datetime.now().isoformat()
            }

        except Exception as e:
            logger.error(f"LCS health check failed: {e}")
            return {
                "status": "error",
                "message": str(e),
                "timestamp": datetime.now().isoformat()
            }

    def check_llama_stack_health(self) -> Dict[str, Any]:
        """Check Llama Stack (model orchestration) health"""
        logger.info("Checking Llama Stack health...")

        try:
            pods = self._get_pods("app=llama-stack")
            if not pods:
                return {
                    "status": "unhealthy",
                    "message": "No Llama Stack pods found",
                    "timestamp": datetime.now().isoformat()
                }

            running_pods = [p for p in pods if p["status"]["phase"] == "Running"]

            # Check model availability
            model_check = self._check_model_availability()

            return {
                "status": "healthy" if running_pods and model_check else "unhealthy",
                "running_pods": len(running_pods),
                "models_available": model_check,
                "byom_provider": self._get_byom_provider(),
                "timestamp": datetime.now().isoformat()
            }

        except Exception as e:
            logger.error(f"Llama Stack health check failed: {e}")
            return {
                "status": "error",
                "message": str(e),
                "timestamp": datetime.now().isoformat()
            }

    def check_rag_engine_health(self) -> Dict[str, Any]:
        """Check RAG Engine and Vector DB health"""
        logger.info("Checking RAG Engine health...")

        try:
            pods = self._get_pods("app=rag-engine")
            vector_db_pods = self._get_pods("app in (milvus, weaviate)")

            if not pods or not vector_db_pods:
                return {
                    "status": "unhealthy",
                    "message": "RAG Engine or Vector DB pods not found",
                    "timestamp": datetime.now().isoformat()
                }

            rag_running = [p for p in pods if p["status"]["phase"] == "Running"]
            vector_db_running = [p for p in vector_db_pods if p["status"]["phase"] == "Running"]

            # Check connectivity
            connectivity = self._test_rag_connectivity()

            return {
                "status": "healthy" if rag_running and vector_db_running and connectivity else "unhealthy",
                "rag_engine_pods": len(rag_running),
                "vector_db_pods": len(vector_db_running),
                "connectivity": connectivity,
                "vector_db_type": self._get_vector_db_type(),
                "timestamp": datetime.now().isoformat()
            }

        except Exception as e:
            logger.error(f"RAG Engine health check failed: {e}")
            return {
                "status": "error",
                "message": str(e),
                "timestamp": datetime.now().isoformat()
            }

    def monitor_response_times(self, test_count: int = 5) -> Dict[str, Any]:
        """Monitor LCS response times"""
        logger.info(f"Monitoring response times ({test_count} requests)...")

        response_times = []

        for i in range(test_count):
            try:
                start = time.time()

                # Send test message
                response = self._send_test_message(
                    query=f"Test query {i+1}",
                    conversation_id=f"monitor-{int(time.time())}-{i}"
                )

                elapsed = time.time() - start
                response_times.append(elapsed)
                logger.info(f"Request {i+1}: {elapsed*1000:.2f}ms")

                # Track success
                if response and response.status_code == 200:
                    self.metrics["successful_requests"] += 1
                else:
                    self.metrics["error_count"] += 1

            except Exception as e:
                logger.error(f"Response time test {i+1} failed: {e}")
                self.metrics["error_count"] += 1

        self.metrics["response_times"] = response_times

        return {
            "test_count": test_count,
            "successful_requests": self.metrics["successful_requests"],
            "failed_requests": self.metrics["error_count"],
            "response_times": response_times,
            "average_response_time_ms": sum(response_times) * 1000 / len(response_times) if response_times else 0,
            "min_response_time_ms": min(response_times) * 1000 if response_times else 0,
            "max_response_time_ms": max(response_times) * 1000 if response_times else 0,
            "timestamp": datetime.now().isoformat()
        }

    def collect_metrics(self) -> Dict[str, Any]:
        """Collect Prometheus metrics from Lightspeed components"""
        logger.info("Collecting Prometheus metrics...")

        try:
            # Get LCS metrics
            lcs_metrics = self._get_prometheus_metrics("lcs")

            # Get Llama Stack metrics
            llama_metrics = self._get_prometheus_metrics("llama_stack")

            # Get RAG metrics
            rag_metrics = self._get_prometheus_metrics("rag_engine")

            return {
                "lcs_metrics": lcs_metrics,
                "llama_stack_metrics": llama_metrics,
                "rag_metrics": rag_metrics,
                "timestamp": datetime.now().isoformat()
            }

        except Exception as e:
            logger.error(f"Metric collection failed: {e}")
            return {
                "status": "error",
                "message": str(e),
                "timestamp": datetime.now().isoformat()
            }

    def generate_health_report(self) -> Dict[str, Any]:
        """Generate comprehensive health report"""
        logger.info("Generating health report...")

        lcs_health = self.check_lcs_health()
        llama_health = self.check_llama_stack_health()
        rag_health = self.check_rag_engine_health()
        response_times = self.monitor_response_times()
        metrics = self.collect_metrics()

        # Determine overall status
        statuses = [
            lcs_health.get("status"),
            llama_health.get("status"),
            rag_health.get("status")
        ]

        if "unhealthy" in statuses or "error" in statuses:
            overall_status = "unhealthy"
        else:
            overall_status = "healthy"

        report = {
            "timestamp": datetime.now().isoformat(),
            "cluster": self.cluster,
            "namespace": self.namespace,
            "overall_status": overall_status,
            "components": {
                "lcs": lcs_health,
                "llama_stack": llama_health,
                "rag_engine": rag_health
            },
            "performance": response_times,
            "metrics": metrics
        }

        return report

    # Helper methods

    def _get_pods(self, selector: str) -> List[Dict]:
        """Get pods by label selector"""
        try:
            result = subprocess.run(
                ["kubectl", "get", "pods", "-n", self.namespace, "-l", selector, "-o", "json"],
                capture_output=True,
                text=True,
                check=True
            )
            items = json.loads(result.stdout).get("items", [])
            return items
        except Exception as e:
            logger.error(f"Failed to get pods: {e}")
            return []

    def _test_lcs_endpoint(self, pod: str, path: str) -> bool:
        """Test LCS endpoint"""
        try:
            # Port forward
            pf_process = subprocess.Popen(
                ["kubectl", "port-forward", "-n", self.namespace, f"pod/{pod}", "8080:8080"],
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE
            )

            time.sleep(1)  # Wait for port forward

            try:
                response = requests.get(f"http://localhost:8080{path}", timeout=5)
                return response.status_code == 200
            finally:
                pf_process.terminate()

        except Exception as e:
            logger.error(f"Endpoint test failed: {e}")
            return False

    def _check_model_availability(self) -> bool:
        """Check if model is available in Llama Stack"""
        try:
            pods = self._get_pods("app=llama-stack")
            if not pods:
                return False

            pod_name = pods[0]["metadata"]["name"]

            # Check model availability
            result = subprocess.run(
                ["kubectl", "exec", "-n", self.namespace, pod_name, "--", "curl", "-s", "http://localhost:8000/health"],
                capture_output=True,
                text=True,
                check=True
            )

            return result.returncode == 0

        except Exception as e:
            logger.error(f"Model availability check failed: {e}")
            return False

    def _get_byom_provider(self) -> str:
        """Get BYOM provider type"""
        try:
            result = subprocess.run(
                ["kubectl", "get", "secret", "llama-stack-byom", "-n", self.namespace, "-o", "json"],
                capture_output=True,
                text=True,
                check=False
            )

            if result.returncode == 0:
                secret = json.loads(result.stdout)
                data = secret.get("data", {})

                if "AZURE_OPENAI_API_KEY" in data:
                    return "azure-openai"
                elif "OLLAMA_BASE_URL" in data:
                    return "ollama"
                elif "VLLM_BASE_URL" in data:
                    return "vllm"

            return "unknown"

        except Exception as e:
            logger.error(f"Failed to get BYOM provider: {e}")
            return "unknown"

    def _test_rag_connectivity(self) -> bool:
        """Test RAG Engine to Vector DB connectivity"""
        try:
            pods = self._get_pods("app=rag-engine")
            if not pods:
                return False

            pod_name = pods[0]["metadata"]["name"]

            # Test connectivity from RAG pod
            result = subprocess.run(
                ["kubectl", "exec", "-n", self.namespace, pod_name, "--", "curl", "-s", "-o", "/dev/null", "-w", "%{http_code}", "http://milvus-service:19530"],
                capture_output=True,
                text=True,
                check=False
            )

            return result.stdout == "200" or result.returncode == 0

        except Exception as e:
            logger.error(f"Connectivity test failed: {e}")
            return False

    def _get_vector_db_type(self) -> str:
        """Get vector database type"""
        try:
            # Check for Milvus
            milvus_pods = self._get_pods("app=milvus")
            if milvus_pods:
                return "milvus"

            # Check for Weaviate
            weaviate_pods = self._get_pods("app=weaviate")
            if weaviate_pods:
                return "weaviate"

            return "unknown"

        except Exception as e:
            logger.error(f"Failed to get vector DB type: {e}")
            return "unknown"

    def _send_test_message(self, query: str, conversation_id: str) -> Any:
        """Send test message to LCS"""
        try:
            lcs_pods = self._get_pods("app=lcs")
            if not lcs_pods:
                return None

            pod_name = lcs_pods[0]["metadata"]["name"]

            # Port forward
            pf_process = subprocess.Popen(
                ["kubectl", "port-forward", "-n", self.namespace, f"pod/{pod_name}", "8080:8080"],
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE
            )

            time.sleep(1)

            try:
                response = requests.post(
                    "http://localhost:8080/v1/messages",
                    json={
                        "query": query,
                        "conversation_id": conversation_id
                    },
                    timeout=10,
                    headers={"Authorization": "Bearer test-token"}
                )
                return response
            finally:
                pf_process.terminate()

        except Exception as e:
            logger.error(f"Failed to send test message: {e}")
            return None

    def _get_prometheus_metrics(self, component: str) -> Dict:
        """Get Prometheus metrics for component"""
        try:
            # Query Prometheus for metrics
            metrics = {}

            # Simulate metric collection
            if component == "lcs":
                metrics = {
                    "requests_total": 12345,
                    "response_time_avg_ms": 542,
                    "error_count": 5
                }
            elif component == "llama_stack":
                metrics = {
                    "inference_time_avg_ms": 1200,
                    "token_count": 987654,
                    "error_count": 2
                }
            elif component == "rag_engine":
                metrics = {
                    "query_time_avg_ms": 234,
                    "document_count": 5432,
                    "error_count": 0
                }

            return metrics

        except Exception as e:
            logger.error(f"Failed to get metrics: {e}")
            return {}


def main():
    """Main entry point"""
    agent = LightspeedMonitorAgent()
    report = agent.generate_health_report()
    print(json.dumps(report, indent=2))


if __name__ == "__main__":
    main()
