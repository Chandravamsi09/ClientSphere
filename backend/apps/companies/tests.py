from decimal import Decimal
from django.contrib.auth import get_user_model
from django.urls import reverse
from rest_framework import status
from rest_framework.test import APITestCase

from .models import Company, CompanyLifecycleStage, CompanySize

User = get_user_model()


class CompanyModuleTests(APITestCase):
    """
    Automated integration test suite for ClientSphere CRM Companies module.
    """

    def setUp(self):
        self.list_create_url = reverse('companies:company-list')

        # Test users
        self.user_a = User.objects.create_user(
            username="rep_alpha",
            email="alpha@clientsphere.com",
            password="SecurePassword123!",
            first_name="Alpha",
            last_name="Manager",
            role="manager",
        )
        self.user_b = User.objects.create_user(
            username="rep_beta",
            email="beta@clientsphere.com",
            password="SecurePassword123!",
            first_name="Beta",
            last_name="Agent",
            role="sales_rep",
        )

        # Baseline company
        self.company = Company.objects.create(
            name="Apex Global Technologies",
            website="https://apexglobal.io",
            industry="Technology",
            company_size=CompanySize.SIZE_51_200,
            annual_revenue=Decimal("15000000.00"),
            phone="+1-800-555-0199",
            email="contact@apexglobal.io",
            city="San Francisco",
            state="California",
            country="USA",
            lifecycle_stage=CompanyLifecycleStage.CUSTOMER,
            owner=self.user_a,
        )

    def detail_url(self, company_id):
        return reverse('companies:company-detail', kwargs={'pk': company_id})

    def test_unauthenticated_requests_blocked(self):
        # List
        res = self.client.get(self.list_create_url)
        self.assertEqual(res.status_code, status.HTTP_401_UNAUTHORIZED)

        # Create
        res = self.client.post(self.list_create_url, {"name": "Shadow Corp"})
        self.assertEqual(res.status_code, status.HTTP_401_UNAUTHORIZED)

    def test_create_company_success_with_default_owner(self):
        self.client.force_authenticate(user=self.user_a)

        payload = {
            "name": "Quantum Dynamics",
            "website": "https://quantumdynamics.ai",
            "industry": "Artificial Intelligence",
            "company_size": "201-500",
            "annual_revenue": "25000000.00",
            "phone": "+1-415-555-0144",
            "email": "info@quantumdynamics.ai",
            "city": "San Jose",
            "state": "California",
            "country": "USA",
            "lifecycle_stage": "prospect",
            "notes": "Enterprise pilot program initiated.",
        }
        response = self.client.post(self.list_create_url, payload, format='json')

        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        data = response.json()
        self.assertEqual(data["name"], "Quantum Dynamics")
        self.assertEqual(data["industry"], "Artificial Intelligence")
        self.assertEqual(data["owner"], self.user_a.id)
        self.assertEqual(data["owner_name"], "Alpha Manager")
        self.assertEqual(data["company_size_display"], "201-500 Employees")
        self.assertEqual(data["lifecycle_stage_display"], "Prospect")
        self.assertIn("created_at", data)

    def test_create_company_validation_errors(self):
        self.client.force_authenticate(user=self.user_a)

        # Missing name
        res = self.client.post(self.list_create_url, {
            "industry": "Healthcare"
        }, format='json')
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn("name", res.json())

        # Duplicate name
        res = self.client.post(self.list_create_url, {
            "name": "Apex Global Technologies",  # matches self.company
        }, format='json')
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn("name", res.json())

    def test_list_companies_pagination(self):
        self.client.force_authenticate(user=self.user_a)

        # Create additional companies
        for i in range(5):
            Company.objects.create(
                name=f"Enterprise Client {i}",
                industry="Consulting",
                owner=self.user_a,
            )

        response = self.client.get(self.list_create_url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        data = response.json()
        self.assertIn("count", data)
        self.assertIn("results", data)
        self.assertEqual(data["count"], 6)  # 1 baseline + 5 created

    def test_search_companies(self):
        self.client.force_authenticate(user=self.user_a)

        Company.objects.create(
            name="Nordic Fintech Solutions",
            industry="Finance",
            city="Stockholm",
            country="Sweden",
            owner=self.user_a,
        )

        # Search by name
        res = self.client.get(f"{self.list_create_url}?search=Nordic")
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.assertEqual(res.json()["count"], 1)
        self.assertEqual(res.json()["results"][0]["name"], "Nordic Fintech Solutions")

        # Search by industry
        res = self.client.get(f"{self.list_create_url}?search=Finance")
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.assertEqual(res.json()["count"], 1)

        # Search by city
        res = self.client.get(f"{self.list_create_url}?search=Stockholm")
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.assertEqual(res.json()["count"], 1)

        # Search with no match
        res = self.client.get(f"{self.list_create_url}?search=NonExistentCompany")
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.assertEqual(res.json()["count"], 0)

    def test_filter_by_lifecycle_stage(self):
        self.client.force_authenticate(user=self.user_a)

        Company.objects.create(
            name="Alpha Partner Group",
            lifecycle_stage=CompanyLifecycleStage.PARTNER,
            owner=self.user_a,
        )

        res = self.client.get(f"{self.list_create_url}?lifecycle_stage=partner")
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        data = res.json()
        self.assertEqual(data["count"], 1)
        self.assertEqual(data["results"][0]["name"], "Alpha Partner Group")

    def test_filter_by_industry(self):
        self.client.force_authenticate(user=self.user_a)

        Company.objects.create(
            name="BioHealth Labs",
            industry="Healthcare",
            owner=self.user_a,
        )

        res = self.client.get(f"{self.list_create_url}?industry=Healthcare")
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.assertEqual(res.json()["count"], 1)
        self.assertEqual(res.json()["results"][0]["name"], "BioHealth Labs")

    def test_filter_by_company_size(self):
        self.client.force_authenticate(user=self.user_a)

        Company.objects.create(
            name="Micro Startup",
            company_size=CompanySize.SIZE_1_10,
            owner=self.user_a,
        )

        res = self.client.get(f"{self.list_create_url}?company_size=1-10")
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.assertEqual(res.json()["count"], 1)
        self.assertEqual(res.json()["results"][0]["name"], "Micro Startup")

    def test_filter_by_mine_ownership(self):
        self.client.force_authenticate(user=self.user_a)

        Company.objects.create(
            name="Beta Accounts Ltd",
            owner=self.user_b,
        )

        # When filtering by mine=true, only user_a's companies are returned
        res = self.client.get(f"{self.list_create_url}?mine=true")
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        data = res.json()
        self.assertEqual(data["count"], 1)
        self.assertEqual(data["results"][0]["id"], self.company.id)

    def test_retrieve_company_detail(self):
        self.client.force_authenticate(user=self.user_a)

        res = self.client.get(self.detail_url(self.company.id))
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        data = res.json()
        self.assertEqual(data["id"], self.company.id)
        self.assertEqual(data["name"], "Apex Global Technologies")
        self.assertEqual(data["website"], "https://apexglobal.io")

        # 404 on non-existent
        res_404 = self.client.get(self.detail_url(99999))
        self.assertEqual(res_404.status_code, status.HTTP_404_NOT_FOUND)

    def test_update_company_put(self):
        self.client.force_authenticate(user=self.user_a)

        payload = {
            "name": "Apex Global Worldwide",
            "website": "https://apexworldwide.com",
            "industry": "Enterprise Software",
            "company_size": "501-1000",
            "annual_revenue": "20000000.00",
            "phone": "+1-800-555-0100",
            "city": "San Francisco",
            "country": "USA",
            "lifecycle_stage": "customer",
        }
        res = self.client.put(self.detail_url(self.company.id), payload, format='json')
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        data = res.json()
        self.assertEqual(data["name"], "Apex Global Worldwide")
        self.assertEqual(data["industry"], "Enterprise Software")
        self.assertEqual(data["company_size"], "501-1000")

    def test_partial_update_company_patch(self):
        self.client.force_authenticate(user=self.user_a)

        patch_payload = {
            "annual_revenue": "30000000.00",
            "lifecycle_stage": "partner",
        }
        res = self.client.patch(self.detail_url(self.company.id), patch_payload, format='json')
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        data = res.json()
        self.assertEqual(float(data["annual_revenue"]), 30000000.00)
        self.assertEqual(data["lifecycle_stage"], "partner")
        # Ensure name remains intact
        self.assertEqual(data["name"], "Apex Global Technologies")

    def test_delete_company(self):
        self.client.force_authenticate(user=self.user_a)

        res = self.client.delete(self.detail_url(self.company.id))
        self.assertEqual(res.status_code, status.HTTP_204_NO_CONTENT)

        # Verify record no longer exists
        self.assertFalse(Company.objects.filter(pk=self.company.id).exists())
        res_after = self.client.get(self.detail_url(self.company.id))
        self.assertEqual(res_after.status_code, status.HTTP_404_NOT_FOUND)
