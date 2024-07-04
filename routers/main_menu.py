from aiogram.fsm.state import State, StatesGroup


class MainMenuStates(StatesGroup):
    main_menu_awaiting_input = State()
