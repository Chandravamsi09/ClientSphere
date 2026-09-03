from datetime import date
from decimal import Decimal
from django.contrib.auth import get_user_model
from django.urls import reverse
from rest_framework import status
from rest_framework.test import APITestCase

from apps.companies.models import Company
from apps.contacts.models import Contact
from .models import Deal, DealStage

User = get_user_model()


class DealModuleTests(APITestCase):
    """
    Automated integration test suite for ClientSphere CRM Deals module.
    """

    def setUp(self):
        self.list_create_url = reverse('deals:deal-list')

        # Test users
        self.user_a = User.objects.create_user(
            username="ae_rep",
            email="ae@clientsphere.com",
            password="SecurePassword123!",
            first_name="Alexander",
            last_name="Pierce",
            role="sales_rep",
        )
        self.user_b = User.objects.create_user(
            username="sales_lead",
            email="lead_ae@clientsphere.com",
            password="SecurePassword123!",
            first_name="Beatrice",
            last_name="Vane",
            role="manager",
        )

        # Related enterprise account and contact
        self.company = Company.objects.create(
            name="Vanguard Industries",
            industry="Manufacturing",
            owner=self.user_a,
        )
        self.contact = Contact.objects.create(
            first_name="Henry",
            last_name="Cavill",
            email="henry@vanguard.com",
            owner=self.user_a,
        )

        # Baseline deal
        self.deal = Deal.objects.create(
            title="Global ERP Integration",
            value=Decimal("200000.00"),
            stage=DealStage.PROPOSAL,
            probability=60,
            close_date=date(2026, 12, 15),
            company=self.company,
            contact=self.contact,
            owner=self.user_a,
        )

    def detail_url(self, deal_id):
        return reverse('deals:deal-detail', kwargs={'pk': deal_id})

    def test_unauthenticated_requests_blocked(self):
        # List
        res = self.client.get(self.list_create_url)
        self.assertEqual(res.status_code, status.HTTP_401_UNAUTHORIZED)

        # Create
        res = self.client.post(self.list_create_url, {"title": "Shadow Deal"})
        self.assertEqual(res.status_code, status.HTTP_401_UNAUTHORIZED)

    def test_create_deal_success_with_default_owner(self):
        self.client.force_authenticate(user=self.user_a)

        payload = {
            "title": "Cloud Infrastructure Expansion",
            "value": "150000.00",
            "stage": "qualification",
            "probability": 40,
            "close_date": "2026-11-30",
            "company": self.company.id,
            "contact": self.contact.id,
            "notes": "Preliminary RFQ received.",
        }
        response = self.client.post(self.list_create_url, payload, format='json')

        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        data = response.json()
        self.assertEqual(data["title"], "Cloud Infrastructure Expansion")
        self.assertEqual(float(data["value"]), 150000.00)
        self.assertEqual(data["stage"], "qualification")
        self.assertEqual(data["stage_display"], "Qualification")
        self.assertEqual(data["probability"], 40)
        # Expected revenue = 150,000 * 0.40 = 60,000
        self.assertEqual(float(data["expected_revenue"]), 60000.00)
        self.assertEqual(data["owner"], self.user_a.id)
        self.assertEqual(data["owner_name"], "Alexander Pierce")
        self.assertEqual(data["company_name"], "Vanguard Industries")
        self.assertEqual(data["contact_name"], "Henry Cavill")
        self.assertIn("created_at", data)

    def test_create_deal_validation_errors(self):
        self.client.force_authenticate(user=self.user_a)

        # Missing title
        res = self.client.post(self.list_create_url, {
            "value": "50000.00"
        }, format='json')
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn("title", res.json())

        # Negative value
        res = self.client.post(self.list_create_url, {
            "title": "Negative Deal",
            "value": "-1000.00"
        }, format='json')
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn("value", res.json())

        # Probability > 100
        res = self.client.post(self.list_create_url, {
            "title": "Overprobable Deal",
            "probability": 150
        }, format='json')
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn("probability", res.json())

    def test_list_deals_pagination(self):
        self.client.force_authenticate(user=self.user_a)

        # Create additional deals
        for i in range(5):
            Deal.objects.create(
                title=f"Deal Contract {i}",
                value=Decimal("50000.00"),
                owner=self.user_a,
            )

        response = self.client.get(self.list_create_url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        data = response.json()
        self.assertIn("count", data)
        self.assertIn("results", data)
        self.assertEqual(data["count"], 6)  # 1 baseline + 5 created

    def test_search_deals(self):
        self.client.force_authenticate(user=self.user_a)

        other_company = Company.objects.create(name="Stark Industries")
        Deal.objects.create(
            title="Arc Reactor License",
            value=Decimal("1000000.00"),
            company=other_company,
            owner=self.user_a,
        )

        # Search by deal title
        res = self.client.get(f"{self.list_create_url}?search=Reactor")
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.assertEqual(res.json()["count"], 1)
        self.assertEqual(res.json()["results"][0]["title"], "Arc Reactor License")

        # Search by company name
        res = self.client.get(f"{self.list_create_url}?search=Stark")
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.assertEqual(res.json()["count"], 1)

        # Search by contact name
        res = self.client.get(f"{self.list_create_url}?search=Henry")
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.assertEqual(res.json()["count"], 1)

        # Search with no match
        res = self.client.get(f"{self.list_create_url}?search=NonExistentDeal")
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.assertEqual(res.json()["count"], 0)

    def test_filter_by_stage(self):
        self.client.force_authenticate(user=self.user_a)

        Deal.objects.create(
            title="Won Deal Contract",
            value=Decimal("80000.00"),
            stage=DealStage.WON,
            owner=self.user_a,
        )

        res = self.client.get(f"{self.list_create_url}?stage=won")
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        data = res.json()
        self.assertEqual(data["count"], 1)
        self.assertEqual(data["results"][0]["title"], "Won Deal Contract")

    def test_filter_by_company(self):
        self.client.force_authenticate(user=self.user_a)

        res = self.client.get(f"{self.list_create_url}?company={self.company.id}")
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        data = res.json()
        self.assertEqual(data["count"], 1)
        self.assertEqual(data["results"][0]["id"], self.deal.id)

    def test_filter_by_contact(self):
        self.client.force_authenticate(user=self.user_a)

        res = self.client.get(f"{self.list_create_url}?contact={self.contact.id}")
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        data = res.json()
        self.assertEqual(data["count"], 1)
        self.assertEqual(data["results"][0]["id"], self.deal.id)

    def test_filter_by_mine_ownership(self):
        self.client.force_authenticate(user=self.user_a)

        Deal.objects.create(
            title="Other Rep Opportunity",
            value=Decimal("60000.00"),
            owner=self.user_b,
        )

        # When filtering by mine=true, only user_a's deals are returned
        res = self.client.get(f"{self.list_create_url}?mine=true")
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        data = res.json()
        self.assertEqual(data["count"], 1)
        self.assertEqual(data["results"][0]["id"], self.deal.id)

    def test_retrieve_deal_detail(self):
        self.client.force_authenticate(user=self.user_a)

        res = self.client.get(self.detail_url(self.deal.id))
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        data = res.json()
        self.assertEqual(data["id"], self.deal.id)
        self.assertEqual(data["title"], "Global ERP Integration")
        self.assertEqual(float(data["value"]), 200000.00)
        # Expected revenue = 200,000 * 0.60 = 120,000
        self.assertEqual(float(data["expected_revenue"]), 120000.00)

        # 404 on non-existent
        res_404 = self.client.get(self.detail_url(99999))
        self.assertEqual(res_404.status_code, status.HTTP_404_NOT_FOUND)

    def test_update_deal_put(self):
        self.client.force_authenticate(user=self.user_a)

        payload = {
            "title": "Global ERP & CRM Integration",
            "value": "250000.00",
            "stage": "negotiation",
            "probability": 80,
            "close_date": "2026-12-31",
            "notes": "Terms and conditions under review.",
        }
        res = self.client.put(self.detail_url(self.deal.id), payload, format='json')
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        data = res.json()
        self.assertEqual(data["title"], "Global ERP & CRM Integration")
        self.assertEqual(float(data["value"]), 250000.00)
        self.assertEqual(data["stage"], "negotiation")
        self.assertEqual(data["probability"], 80)
        # Expected revenue = 250,000 * 0.80 = 200,000
        self.assertEqual(float(data["expected_revenue"]), 200000.00)

    def test_partial_update_deal_patch(self):
        self.client.force_authenticate(user=self.user_a)

        patch_payload = {
            "stage": "won",
            "probability": 100,
        }
        res = self.client.patch(self.detail_url(self.deal.id), patch_payload, format='json')
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        data = res.json()
        self.assertEqual(data["stage"], "won")
        self.assertEqual(data["probability"], 100)
        # Expected revenue = 200,000 * 1.00 = 200,000
        self.assertEqual(float(data["expected_revenue"]), 200000.00)
        # Title remains intact
        self.assertEqual(data["title"], "Global ERP Integration")

    def test_delete_deal(self):
        self.client.force_authenticate(user=self.user_a)

        res = self.client.delete(self.detail_url(self.deal.id))
        self.assertEqual(res.status_code, status.HTTP_204_NO_CONTENT)

        # Verify record no longer exists
        self.assertFalse(Deal.objects.filter(pk=self.deal.id).exists())
        res_after = self.client.get(self.detail_url(self.deal.id))
        self.assertEqual(res_after.status_code, status.HTTP_404_NOT_FOUND)
