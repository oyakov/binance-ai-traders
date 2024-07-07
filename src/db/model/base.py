# AsyncAttrs mixin is added to the Base here
# to use awaitable attributes fecture in order to use attribute lazy-loading along with asyncio
from sqlalchemy.ext.asyncio import AsyncAttrs
from sqlalchemy.orm import DeclarativeBase


class Base(AsyncAttrs, DeclarativeBase):
    pass
