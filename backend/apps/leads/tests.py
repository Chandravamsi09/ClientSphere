from decimal import Decimal
from django.contrib.auth import get_user_model
from django.urls import reverse
from rest_framework import status
from rest_framework.test import APITestCase

from .models import Lead, LeadSource, LeadStatus

User = get_user_model()


class LeadModuleTests(APITestCase):
    """
    Automated integration test suite for ClientSphere CRM Leads module.
    """

    def setUp(self):
        self.list_create_url = reverse('leads:lead-list')

        # Test users
        self.user_a = User.objects.create_user(
            username="sdr_agent",
            email="sdr@clientsphere.com",
            password="SecurePassword123!",
            first_name="Samantha",
            last_name="Drake",
            role="sales_rep",
        )
        self.user_b = User.objects.create_user(
            username="ae_agent",
            email="ae@clientsphere.com",
            password="SecurePassword123!",
            first_name="Arthur",
            last_name="Evans",
            role="sales_rep",
        )

        # Baseline lead
        self.lead = Lead.objects.create(
            first_name="David",
            last_name="Miller",
            email="david.miller@prospectcorp.com",
            phone="+1-555-0188",
            company_name="Prospect Corp",
            job_title="VP Sales",
            status=LeadStatus.NEW,
            source=LeadSource.WEBSITE,
            estimated_value=Decimal("75000.00"),
            owner=self.user_a,
        )

    def detail_url(self, lead_id):
        return reverse('leads:lead-detail', kwargs={'pk': lead_id})

    def test_unauthenticated_requests_blocked(self):
        # List
        res = self.client.get(self.list_create_url)
        self.assertEqual(res.status_code, status.HTTP_401_UNAUTHORIZED)

        # Create
        res = self.client.post(self.list_create_url, {"first_name": "Ghost", "last_name": "Lead"})
        self.assertEqual(res.status_code, status.HTTP_401_UNAUTHORIZED)

    def test_create_lead_success_with_default_owner(self):
        self.client.force_authenticate(user=self.user_a)

        payload = {
            "first_name": "Elena",
            "last_name": "Rostova",
            "email": "elena.rostova@globaltech.com",
            "phone": "+1-555-0177",
            "company_name": "GlobalTech Enterprises",
            "job_title": "Director of IT",
            "status": "contacted",
            "source": "referral",
            "estimated_value": "120000.00",
            "notes": "Interested in enterprise CRM migration.",
        }
        response = self.client.post(self.list_create_url, payload, format='json')

        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        data = response.json()
        self.assertEqual(data["first_name"], "Elena")
        self.assertEqual(data["last_name"], "Rostova")
        self.assertEqual(data["full_name"], "Elena Rostova")
        self.assertEqual(data["email"], "elena.rostova@globaltech.com")
        self.assertEqual(data["owner"], self.user_a.id)
        self.assertEqual(data["owner_name"], "Samantha Drake")
        self.assertEqual(data["status_display"], "Contacted")
        self.assertEqual(data["source_display"], "Referral")
        self.assertIn("created_at", data)

    def test_create_lead_validation_errors(self):
        self.client.force_authenticate(user=self.user_a)

        # Missing first_name & last_name
        res = self.client.post(self.list_create_url, {
            "email": "incomplete@leadcorp.com"
        }, format='json')
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn("first_name", res.json())
        self.assertIn("last_name", res.json())

        # Duplicate email
        res = self.client.post(self.list_create_url, {
            "first_name": "Duplicate",
            "last_name": "Lead",
            "email": "david.miller@prospectcorp.com",  # matches self.lead
        }, format='json')
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn("email", res.json())

    def test_list_leads_pagination(self):
        self.client.force_authenticate(user=self.user_a)

        # Create additional leads
        for i in range(5):
            Lead.objects.create(
                first_name=f"InboundFirst{i}",
                last_name=f"InboundLast{i}",
                email=f"inbound{i}@prospects.io",
                owner=self.user_a,
            )

        response = self.client.get(self.list_create_url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        data = response.json()
        self.assertIn("count", data)
        self.assertIn("results", data)
        self.assertEqual(data["count"], 6)  # 1 baseline + 5 created

    def test_search_leads(self):
        self.client.force_authenticate(user=self.user_a)

        Lead.objects.create(
            first_name="Liam",
            last_name="Neely",
            email="liam@cloudscale.net",
            company_name="CloudScale Infrastructure",
            owner=self.user_a,
        )

        # Search by company name
        res = self.client.get(f"{self.list_create_url}?search=CloudScale")
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.assertEqual(res.json()["count"], 1)
        self.assertEqual(res.json()["results"][0]["first_name"], "Liam")

        # Search by first name
        res = self.client.get(f"{self.list_create_url}?search=David")
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.assertEqual(res.json()["count"], 1)

        # Search with no match
        res = self.client.get(f"{self.list_create_url}?search=NonExistentLead")
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.assertEqual(res.json()["count"], 0)

    def test_filter_by_status(self):
        self.client.force_authenticate(user=self.user_a)

        Lead.objects.create(
            first_name="Sophia",
            last_name="Chen",
            email="sophia@chencorp.com",
            status=LeadStatus.QUALIFIED,
            owner=self.user_a,
        )

        res = self.client.get(f"{self.list_create_url}?status=qualified")
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        data = res.json()
        self.assertEqual(data["count"], 1)
        self.assertEqual(data["results"][0]["email"], "sophia@chencorp.com")

    def test_filter_by_source(self):
        self.client.force_authenticate(user=self.user_a)

        Lead.objects.create(
            first_name="Carlos",
            last_name="Santana",
            email="carlos@latinmusic.com",
            source=LeadSource.EVENT,
            owner=self.user_a,
        )

        res = self.client.get(f"{self.list_create_url}?source=event")
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.assertEqual(res.json()["count"], 1)
        self.assertEqual(res.json()["results"][0]["email"], "carlos@latinmusic.com")

    def test_filter_by_mine_ownership(self):
        self.client.force_authenticate(user=self.user_a)

        Lead.objects.create(
            first_name="Other",
            last_name="OwnerLead",
            email="other@external.org",
            owner=self.user_b,
        )

        # When filtering by mine=true, only user_a's leads are returned
        res = self.client.get(f"{self.list_create_url}?mine=true")
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        data = res.json()
        self.assertEqual(data["count"], 1)
        self.assertEqual(data["results"][0]["id"], self.lead.id)

    def test_retrieve_lead_detail(self):
        self.client.force_authenticate(user=self.user_a)

        res = self.client.get(self.detail_url(self.lead.id))
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        data = res.json()
        self.assertEqual(data["id"], self.lead.id)
        self.assertEqual(data["email"], "david.miller@prospectcorp.com")
        self.assertEqual(float(data["estimated_value"]), 75000.00)

        # 404 on non-existent
        res_404 = self.client.get(self.detail_url(99999))
        self.assertEqual(res_404.status_code, status.HTTP_404_NOT_FOUND)

    def test_update_lead_put(self):
        self.client.force_authenticate(user=self.user_a)

        payload = {
            "first_name": "David",
            "last_name": "Miller Jr.",
            "email": "david.miller@prospectcorp.com",
            "phone": "+1-555-0199",
            "company_name": "Prospect Corp Holdings",
            "job_title": "Chief Commercial Officer",
            "status": "qualified",
            "source": "website",
            "estimated_value": "95000.00",
            "notes": "Upgraded evaluation scope.",
        }
        res = self.client.put(self.detail_url(self.lead.id), payload, format='json')
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        data = res.json()
        self.assertEqual(data["last_name"], "Miller Jr.")
        self.assertEqual(data["job_title"], "Chief Commercial Officer")
        self.assertEqual(data["status"], "qualified")
        self.assertEqual(float(data["estimated_value"]), 95000.00)

    def test_partial_update_lead_patch(self):
        self.client.force_authenticate(user=self.user_a)

        patch_payload = {
            "status": "converted",
            "estimated_value": "110000.00",
        }
        res = self.client.patch(self.detail_url(self.lead.id), patch_payload, format='json')
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        data = res.json()
        self.assertEqual(data["status"], "converted")
        self.assertEqual(float(data["estimated_value"]), 110000.00)
        # Ensure name remains intact
        self.assertEqual(data["first_name"], "David")

    def test_delete_lead(self):
        self.client.force_authenticate(user=self.user_a)

        res = self.client.delete(self.detail_url(self.lead.id))
        self.assertEqual(res.status_code, status.HTTP_204_NO_CONTENT)

        # Verify record no longer exists
        self.assertFalse(Lead.objects.filter(pk=self.lead.id).exists())
        res_after = self.client.get(self.detail_url(self.lead.id))
        self.assertEqual(res_after.status_code, status.HTTP_404_NOT_FOUND)
