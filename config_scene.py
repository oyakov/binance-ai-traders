from aiogram import F
from aiogram.fsm.scene import Scene, on
from aiogram.utils.keyboard import ReplyKeyboardBuilder
from aiogram.fsm.context import FSMContext
from aiogram.types import KeyboardButton, Message, ReplyKeyboardRemove
from aiogram.utils.formatting import (
    Text,
    Bold,
    as_key_value,
    as_list,
    as_numbered_list,
    as_section,
)

from typing import Any
from advertisment import CustomerAd
from dataclasses import dataclass
import logging

@dataclass
class ConfigStep:
    """
    Descripes Step of scene
    """
    id: str
    text: str

substates = [
    ConfigStep("customer", "Введите имя заказчика (лучше всего ник в телеграме)"),
    ConfigStep("text", "Введите текст сообщения"),
    ConfigStep("interval", "Задайте временной интервал"),
]

class ConfigScene(Scene, state="config"):
    """
    This class represents a scene for a config interaction.

    It inherits from Scene class and is associated with the state "config".
    It handles the of periodic message configuration.
    """

    @on.message.enter()
    async def on_enter(self, message: Message, state: FSMContext, step: int | None = 0) -> Any:
        """
        Method triggered when the user enters the quiz scene.

        It displays the current question and answer options to the user.

        :param message:
        :param state:
        :param step: Scene argument, can be passed to the scene using the wizard
        :return:
        """
        if not step:
            # This is the first step, so we should greet the user
            await message.answer("Это диалог добавления нового периодического сообщения")
        
        
        markup = ReplyKeyboardBuilder()
        if step > 0:
            markup.button(text="🔙 Back")
        markup.button(text="🚫 Exit")

        ad = CustomerAd()
        await state.update_data(ad=ad)
        await state.update_data(step=step)  
        
        try:
            step: ConfigStep = substates[step]
        except IndexError:
            # This error means that the question's list is over
            return await self.wizard.exit()

        return await message.answer(
            text=step.text,
            reply_markup=markup.adjust(2).as_markup(resize_keyboard=True)
        )
    
    @on.message.exit()
    async def on_exit(self, message: Message, state: FSMContext) -> None:
        """
        Method triggered when the user exits the quiz scene.

        It calculates the user's answers, displays the summary, and clears the stored answers.

        :param message:
        :param state:
        :return:
        """
        data = await state.get_data()
        ad: CustomerAd = data.get("ad", {})
        content = as_list(
            as_key_value(
                Bold("Заказчик"), ad.customer_name
            ),
            "",
            as_key_value(
                Text("Текст"), ad.text
            ),
            "",
            as_key_value(
                Text("Интервал, часов"), ad.period_millis / 3600000
            )
        )
        logging.info(content)
        await message.answer(**content.as_kwargs(), reply_markup=ReplyKeyboardRemove())

    @on.message(F.text == "🔙 Back")
    async def back(self, message: Message, state: FSMContext) -> None:
        """
        Method triggered when the user selects the "Back" button.

        It allows the user to go back to the previous question.

        :param message:
        :param state:
        :return:
        """
        data = await state.get_data()
        step = data["step"]

        previous_step = step - 1
        if previous_step < 0:
            # In case when the user tries to go back from the first question,
            # we just exit the quiz
            return await self.wizard.exit()
        return await self.wizard.back(step=previous_step)
    
    @on.message(F.text == "🚫 Exit")
    async def exit(self, message: Message) -> None:
        """
        Method triggered when the user selects the "Exit" button.

        It exits the quiz.

        :param message:
        :return:
        """
        await self.wizard.exit()

    @on.message(F.text)
    async def answer(self, message: Message, state: FSMContext) -> None:
        """
        Method triggered when the user selects an answer.

        It stores the answer and proceeds to the next question.

        :param message:
        :param state:
        :return:
        """
        data = await state.get_data()
        step = data["step"]
        substate: ConfigStep = substates[step]
        ad: CustomerAd = data["ad"]
        setattr(ad, substate.id, message.text)
        await self.wizard.retake(step=step + 1)

    @on.message()
    async def unknown_message(self, message: Message) -> None:
        """
        Method triggered when the user sends a message that is not a command or an answer.

        It asks the user to select an answer.

        :param message: The message received from the user.
        :return: None
        """
        await message.answer("Please select an answer.")