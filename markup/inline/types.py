class DateSelector:
    key: str
    text: str
    enabled: bool

    def __init__(self, key: str, text: str, enabled: bool):
        self.key = key
        self.text = text
        self.enabled = enabled

    def __str__(self) -> str:
        return f'Date Selector (key:{self.key}, text:{self.text}, enabled:{self.enabled})'


def days_of_the_week() -> list[DateSelector]:
    return [
                DateSelector('monday', 'Понедельник', True),
                DateSelector('tuesday', 'Вторник', True),
                DateSelector('wednesday', 'Среда', True),
                DateSelector('thursday', 'Четверг', True),
                DateSelector('friday', 'Пятница', True),
                DateSelector('saturday', 'Суббота', True),
                DateSelector('sunday', 'Воскресенье', True),
            ]

def times_of_the_day() -> list[DateSelector]:
    return [
                DateSelector('time10', '10:00', True),
                DateSelector('time12', '12:00', True),
                DateSelector('time14', '14:00', True),
                DateSelector('time16', '16:00', True),
                DateSelector('time18', '18:00', True),
                DateSelector('time20', '20:00', True),
                DateSelector('time22', '22:00', True),
            ]

class TelegramGroup:
    telegram_name: str
    friendly_name: str

    def __init__(self, telegram_name: str, friendly_name: str):
        self.telegram_name = telegram_name
        self.friendly_name = friendly_name

    def __str__(self) -> str:
        return f'Telegram Group (telegram_name:{self.telegram_name}, friendly_name:{self.friendly_name})'
    
def static_groups_mock():
    return [
        TelegramGroup('https://t.me/beograd_service', 'Белградский Консьерж'),
        TelegramGroup('https://t.me/ruskie_v_belgrade', 'Русские в Белграде')
    ]