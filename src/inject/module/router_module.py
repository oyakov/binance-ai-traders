from injector import Module, singleton, provider

from routers.base_router import BaseRouter
from routers.new_message_router import new_message_router


class RouterModule(Module):
    @singleton
    @provider
    def provide_new_message_router(self) -> BaseRouter:
        return new_message_router
