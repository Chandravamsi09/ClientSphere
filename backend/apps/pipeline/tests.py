from decimal import Decimal
from django.contrib.auth import get_user_model
from django.urls import reverse
from rest_framework import status
from rest_framework.test import APITestCase

from apps.deals.models import Deal, DealStage
from .models import Pipeline, PipelineStage

User = get_user_model()


class SalesPipelineModuleTests(APITestCase):
    """
    Automated integration test suite for ClientSphere Sales Pipeline module.
    """

    def setUp(self):
        self.pipeline_list_url = reverse('pipeline:pipeline-list')
        self.stage_list_url = reverse('pipeline:pipeline-stage-list')
        self.default_pipeline_url = reverse('pipeline:pipeline-default')
        self.board_url = reverse('pipeline:pipeline-board')

        # Test user
        self.user = User.objects.create_user(
            username="pipeline_lead",
            email="pipeline.lead@clientsphere.com",
            password="SecurePassword123!",
            first_name="Victoria",
            last_name="Chase",
            role="manager",
        )

        # Baseline Pipeline
        self.pipeline = Pipeline.objects.create(
            name="Enterprise Sales Process",
            description="High ACV enterprise deal pipeline.",
            is_default=True,
            is_active=True,
            owner=self.user,
        )

        # Baseline Stages
        self.stage_prospecting = PipelineStage.objects.create(
            pipeline=self.pipeline,
            name="Prospecting",
            order=1,
            probability=10,
        )
        self.stage_proposal = PipelineStage.objects.create(
            pipeline=self.pipeline,
            name="Proposal",
            order=2,
            probability=50,
        )
        self.stage_won = PipelineStage.objects.create(
            pipeline=self.pipeline,
            name="Closed Won",
            order=3,
            probability=100,
            is_won=True,
        )

    def pipeline_detail_url(self, pk):
        return reverse('pipeline:pipeline-detail', kwargs={'pk': pk})

    def pipeline_summary_url(self, pk):
        return reverse('pipeline:pipeline-summary', kwargs={'pk': pk})

    def stage_detail_url(self, pk):
        return reverse('pipeline:pipeline-stage-detail', kwargs={'pk': pk})

    def stage_reorder_url(self, pk):
        return reverse('pipeline:pipeline-stage-reorder', kwargs={'pk': pk})

    def test_unauthenticated_requests_blocked(self):
        res = self.client.get(self.pipeline_list_url)
        self.assertEqual(res.status_code, status.HTTP_401_UNAUTHORIZED)

        res = self.client.get(self.board_url)
        self.assertEqual(res.status_code, status.HTTP_401_UNAUTHORIZED)

        res = self.client.post(self.pipeline_list_url, {"name": "Shadow Pipeline"})
        self.assertEqual(res.status_code, status.HTTP_401_UNAUTHORIZED)

    def test_create_pipeline_success_with_default_owner(self):
        self.client.force_authenticate(user=self.user)

        payload = {
            "name": "Mid-Market Pipeline",
            "description": "Mid-tier B2B accounts pipeline.",
            "is_active": True,
            "is_default": False,
        }
        res = self.client.post(self.pipeline_list_url, payload, format='json')
        self.assertEqual(res.status_code, status.HTTP_201_CREATED)
        data = res.json()
        self.assertEqual(data["name"], "Mid-Market Pipeline")
        self.assertEqual(data["owner"], self.user.id)
        self.assertEqual(data["owner_name"], "Victoria Chase")
        self.assertIn("created_at", data)

    def test_create_pipeline_validation_errors(self):
        self.client.force_authenticate(user=self.user)

        # Blank name
        res = self.client.post(self.pipeline_list_url, {"name": "  "}, format='json')
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn("name", res.json())

        # Duplicate name
        res = self.client.post(self.pipeline_list_url, {"name": "Enterprise Sales Process"}, format='json')
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn("name", res.json())

    def test_default_pipeline_action_bootstrap(self):
        self.client.force_authenticate(user=self.user)

        # Clear existing default
        Pipeline.objects.all().delete()

        res = self.client.get(self.default_pipeline_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        data = res.json()
        self.assertEqual(data["name"], "Standard Sales Pipeline")
        self.assertTrue(data["is_default"])
        self.assertEqual(data["stages_count"], 6)

        # Verify stages were created
        stage_names = [s["name"] for s in data["stages"]]
        self.assertIn("Prospecting", stage_names)
        self.assertIn("Closed Won", stage_names)
        self.assertIn("Closed Lost", stage_names)

    def test_pipeline_board_endpoint_with_deals(self):
        self.client.force_authenticate(user=self.user)

        # Create deals in various stages
        Deal.objects.create(
            title="Enterprise Deal Alpha",
            value=Decimal("100000.00"),
            stage=DealStage.PROPOSAL,
            probability=50,
            owner=self.user,
        )
        Deal.objects.create(
            title="Enterprise Deal Beta",
            value=Decimal("50000.00"),
            stage=DealStage.WON,
            probability=100,
            owner=self.user,
        )

        res = self.client.get(self.board_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        data = res.json()
        self.assertIn("pipeline", data)
        self.assertIn("metrics", data)
        self.assertIn("stages", data)

        metrics = data["metrics"]
        self.assertEqual(metrics["total_deals"], 2)
        self.assertEqual(float(metrics["won_value"]), 50000.00)
        self.assertEqual(float(metrics["win_rate_percentage"]), 50.0)

        # Ensure stages are returned with columns
        self.assertGreaterEqual(len(data["stages"]), 3)

    def test_pipeline_summary_endpoint(self):
        self.client.force_authenticate(user=self.user)

        Deal.objects.create(
            title="Strategic Account",
            value=Decimal("80000.00"),
            stage=DealStage.PROSPECTING,
            owner=self.user,
        )

        res = self.client.get(self.pipeline_summary_url(self.pipeline.id))
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        data = res.json()
        self.assertEqual(data["pipeline_id"], self.pipeline.id)
        self.assertEqual(data["pipeline_name"], "Enterprise Sales Process")
        self.assertEqual(data["total_stages"], 3)
        self.assertIn("stages", data)

    def test_list_pipelines_filtering_and_search(self):
        self.client.force_authenticate(user=self.user)

        Pipeline.objects.create(
            name="Inbound Self-Serve",
            is_active=False,
            is_default=False,
            owner=self.user,
        )

        # Filter by is_active=false
        res = self.client.get(f"{self.pipeline_list_url}?is_active=false")
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.assertEqual(res.json()["count"], 1)
        self.assertEqual(res.json()["results"][0]["name"], "Inbound Self-Serve")

        # Search
        res = self.client.get(f"{self.pipeline_list_url}?search=Enterprise")
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.assertEqual(res.json()["count"], 1)

    def test_stage_crud(self):
        self.client.force_authenticate(user=self.user)

        # Create stage
        stage_payload = {
            "pipeline": self.pipeline.id,
            "name": "Contract Review",
            "order": 4,
            "probability": 85,
        }
        res = self.client.post(self.stage_list_url, stage_payload, format='json')
        self.assertEqual(res.status_code, status.HTTP_201_CREATED)
        stage_id = res.json()["id"]

        # Validate probability > 100
        bad_payload = {
            "pipeline": self.pipeline.id,
            "name": "Invalid Stage",
            "order": 5,
            "probability": 120,
        }
        res_bad = self.client.post(self.stage_list_url, bad_payload, format='json')
        self.assertEqual(res_bad.status_code, status.HTTP_400_BAD_REQUEST)

        # Update stage
        res_update = self.client.patch(self.stage_detail_url(stage_id), {"probability": 90}, format='json')
        self.assertEqual(res_update.status_code, status.HTTP_200_OK)
        self.assertEqual(res_update.json()["probability"], 90)

        # Delete stage
        res_del = self.client.delete(self.stage_detail_url(stage_id))
        self.assertEqual(res_del.status_code, status.HTTP_204_NO_CONTENT)

    def test_stage_reorder_action(self):
        self.client.force_authenticate(user=self.user)

        # Reorder stage
        res = self.client.post(
            self.stage_reorder_url(self.stage_prospecting.id),
            {"order": 5},
            format='json'
        )
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.assertEqual(res.json()["order"], 5)

        # Invalid reorder payload
        res_bad = self.client.post(
            self.stage_reorder_url(self.stage_prospecting.id),
            {"order": -1},
            format='json'
        )
        self.assertEqual(res_bad.status_code, status.HTTP_400_BAD_REQUEST)
