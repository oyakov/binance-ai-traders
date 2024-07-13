from aiogram import Router

from oam import log_config
from db.repository.admin_user_repository import AdminUserRepository
from db.repository.calendar_repository import CalendarRepository
from db.repository.telegram_group_repository import TelegramGroupRepository
from db.repository.worker_bot_instance_repository import WorkerBotInstanceRepository
from middleware.chat_id_middleware import ChatIDMiddleware
from middleware.service_middleware import ServiceMiddleware
from service.openai.openai_api_service import OpenAIAPIService
from service.telegram_service import TelegramService

logger = log_config.get_logger(__name__)


class BaseRouter(Router):
    # Define a static structure for middleware configurations
    repositories = [
        {
            'name': 'tg_group_repository',
            'service_class': TelegramGroupRepository
        },
        {
            'name': 'calendar_repository',
            'service_class': CalendarRepository
        },
        {
            'name': 'admin_user_repository',
            'service_class': AdminUserRepository
        },
        {
            'name': 'worker_bot_instance_repository',
            'service_class': WorkerBotInstanceRepository
        }
        # Add more service configurations as needed
    ]

    services = [
        {
            'name': 'tg_group_service',
            'service_class': TelegramService
        },
        {
            'name': 'openai_service',
            'service_class': OpenAIAPIService
        },
        # Add more service configurations as needed
    ]

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.install_injection_middlewares()

    def install_injection_middlewares(self):
        # Iterate over the repository configurations
        for repo in self.repositories:
            # Create an instance of the middleware
            middleware_instance = ServiceMiddleware(repo['name'], repo['service_class']())
            # Add the middleware to the router
            self.message.middleware(middleware_instance)
            self.callback_query.middleware(middleware_instance)

        # Iterate over the service configurations
        for service in self.services:
            # Create an instance of the middleware
            middleware_instance = ServiceMiddleware(service['name'], service['service_class']())
            # Add the middleware to the router
            self.message.middleware(middleware_instance)
            self.callback_query.middleware(middleware_instance)

    def install_data_collection_middleware(self):
        # Create an instance of the middleware
        middleware_instance = ChatIDMiddleware()
        # Add the middleware to the router
        self.message.middleware(middleware_instance)
        self.callback_query.middleware(middleware_instance)
