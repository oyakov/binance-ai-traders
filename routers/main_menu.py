from aiogram.fsm.state import State, StatesGroup


class MainMenu(StatesGroup):
    main_menu_awaiting_input = State()
