from aiogram.types import (
    InlineKeyboardMarkup,
    InlineKeyboardButton,
)


def day_of_the_week_picker_inline(selected_days):
        days_of_week = [
            ('Понедельник', 'monday'),
            ('Вторник', 'tuesday'),
            ('Среда', 'wednesday'),
            ('Четверг', 'thursday'),
            ('Пятница', 'friday'),
            ('Суббота', 'saturday'),
            ('Воскресенье', 'sunday')
        ]
        buttons = []
        for day, callback_data in days_of_week:
                is_selected = selected_days.get(callback_data, False)
                text = f"{day} {'✅' if is_selected else '❌'}"
                callback_data = f"toggle_{day}"
                buttons.append(InlineKeyboardButton(text=text, callback_data=callback_data))
        buttons.append(InlineKeyboardButton(text="Назад 🔙", callback_data='back'))
        return InlineKeyboardMarkup(inline_keyboard=[buttons])

def day_of_the_month_picker_inline(selected_days):        
        buttons = []
        for day, selected in selected_days:
                text = f"{day} {'✅' if selected else '❌'}"
                callback_data = f"toggle_{day}"
                buttons.append(InlineKeyboardButton(text=text, callback_data=callback_data))
        buttons.append(InlineKeyboardButton(text="Назад 🔙", callback_data='back'))
        return InlineKeyboardMarkup(inline_keyboard=[buttons])

def month_of_the_year_picker_inline(selected_months):        
        buttons = []
        for month, selected in selected_months:
                text = f"{month} {'✅' if selected else '❌'}"
                callback_data = f"toggle_{month}"
                buttons.append(InlineKeyboardButton(text=text, callback_data=callback_data))
        buttons.append(InlineKeyboardButton(text="Назад 🔙", callback_data='back'))
        return InlineKeyboardMarkup(inline_keyboard=[buttons])

def time_of_the_day_picker_inline(selected_times):
        days_of_week = [
            ('10:00', 'time10'),
            ('12:00', 'time12'),
            ('14:00', 'time14'),
            ('16:00', 'time16'),
            ('18:00', 'time18'),
            ('20:00', 'time20'),
            ('22:00', 'time22')
        ]
        buttons = []
        for time, selected in selected_times:
                text = f"{time} {'✅' if selected else '❌'}"
                callback_data = f"toggle_{time}"
                buttons.append(InlineKeyboardButton(text=text, callback_data=callback_data))
        buttons.append(InlineKeyboardButton(text="Назад 🔙", callback_data='back'))
        return InlineKeyboardMarkup(inline_keyboard=[buttons])