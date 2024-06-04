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