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
                DateSelector('10_00', '10:00', True),
                DateSelector('12_00', '12:00', True),
                DateSelector('14_00', '14:00', True),
                DateSelector('16_00', '16:00', True),
                DateSelector('18_00', '18:00', True),
                DateSelector('20_00', '20:00', True),
                DateSelector('22_00', '22:00', True),
            ]

def months_of_the_year() -> list[DateSelector]:
    return [
                DateSelector('january', 'January', True),
                DateSelector('february', 'February', True),
                DateSelector('march', 'March', True),
                DateSelector('april', 'April', True),
                DateSelector('june', 'June', True),
                DateSelector('july', 'July', True),
                DateSelector('august', 'August', True),
                DateSelector('september', 'September', True),
                DateSelector('october', 'October', True),
                DateSelector('november', 'November', True),
                DateSelector('december', 'December', True),
            ]

def days_of_the_month() -> list[DateSelector]:
    return [
                DateSelector('1', '1', True),
                DateSelector('2', '2', True),
                DateSelector('3', '3', True),
                DateSelector('4', '4', True),
                DateSelector('5', '5', True),
                DateSelector('6', '6', True),
                DateSelector('7', '7', True),
                DateSelector('8', '8', True),
                DateSelector('9', '9', True),
                DateSelector('10', '10', True),
                DateSelector('11', '11', True),
                DateSelector('12', '12', True),
                DateSelector('13', '13', True),
                DateSelector('14', '14', True),
                DateSelector('15', '15', True),
                DateSelector('16', '16', True),
                DateSelector('17', '17', True),
                DateSelector('18', '18', True),
                DateSelector('19', '19', True),
                DateSelector('20', '20', True),
                DateSelector('21', '21', True),
                DateSelector('22', '22', True),
                DateSelector('23', '23', True),
                DateSelector('24', '24', True),
                DateSelector('25', '25', True),
                DateSelector('26', '26', True),
                DateSelector('27', '27', True),
                DateSelector('28', '28', True),
                DateSelector('29', '29', True),
                DateSelector('30', '30', True),
            ]