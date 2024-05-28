from dataclasses import dataclass

@dataclass
class CustomerAd:
    """
    Represents an answer to a question.
    """


    customer_name: str = ""
    """Name of the customer"""
    text: str = ""
    """The answer text"""
    period_millis: int = 24 * 3600 * 1000
    """Indicates if the answer is correct"""