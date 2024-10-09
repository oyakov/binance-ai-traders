from aiogram import Router

from middleware.chat_id_middleware import ChatIDMiddleware
from middleware.service_middleware import ServiceMiddleware
from oam import log_config

logger = log_config.get_logger(__name__)


class BaseRouter(Router):

    def __init__(self, services, repositories, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.subsystem_manager = None
        self.services = services
        self.repositories = repositories
        self.install_injection_middlewares()

    def initialize(self, subsystem_manager):
        self.subsystem_manager = subsystem_manager

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
