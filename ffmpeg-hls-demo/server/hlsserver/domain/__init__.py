from base64 import urlsafe_b64encode
from dataclasses import dataclass
import fastjsonschema

@dataclass
class Radio:
    validate = staticmethod(fastjsonschema.compile({
        "type": "object",
        "properties": {
            "url": {
                "type": "string"
            },
            "name": {
                "type": "string"
            }
        },
        "required": ["url", "name"]
    }))

    @classmethod
    def create(cls, data):
        cls.validate(data)
        return cls(**data)

    url: str
    name: str

@dataclass
class PersistedRadio:
    @classmethod
    def create(cls, radio):
        return cls(radio, urlsafe_b64encode(radio.name.encode("utf-8")).decode("utf-8"))

    radio: Radio
    key: str
