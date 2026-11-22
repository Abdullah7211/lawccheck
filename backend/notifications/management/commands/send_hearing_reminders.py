
from datetime import timedelta

from django.core.management.base import BaseCommand
from django.utils import timezone

from hearings.models import Hearing
from notifications.models import Notification


class Command(BaseCommand):
    help = 'Create automatic notifications for upcoming hearings.'

    def handle(self, *args, **options):
        today = timezone.localdate()

        reminder_days = [7, 3, 1]
        created_count = 0

        for days in reminder_days:
            target_date = today + timedelta(days=days)

            hearings = Hearing.objects.filter(
                hearing_date=target_date,
                status='scheduled'
            ).select_related('case', 'case__lawyer')

            for hearing in hearings:
                lawyer = hearing.case.lawyer

                key = f'hearing-{hearing.id}-{days}-days'

                notification, created = Notification.objects.get_or_create(
                    deduplication_key=key,
                    defaults={
                        'lawyer': lawyer,
                        'title': f'Hearing Reminder: {days} days left',
                        'message': (
                            f'Your case "{hearing.case.title}" has a '
                            f'hearing scheduled on {hearing.hearing_date}. '
                            f'There are {days} days remaining.'
                        ),
                        'notification_type': 'hearing',
                    }
                )

                if created:
                    created_count += 1

        self.stdout.write(
            self.style.SUCCESS(
                f'Hearing reminder check completed. '
                f'{created_count} notification(s) created.'
            )
        )
