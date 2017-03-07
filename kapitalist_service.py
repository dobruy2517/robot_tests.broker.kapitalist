# -*- coding: utf-8 -
import string

from iso8601 import parse_date
import dateutil.parser


def get_all_dates(initial_tender_data, key, subkey=None):
    tender_period = initial_tender_data.data.tenderPeriod
    enquiry_period = initial_tender_data.data.enquiryPeriod
    end_period = dateutil.parser.parse(enquiry_period['endDate'])
    start_dt = dateutil.parser.parse(tender_period['startDate'])
    end_dt = dateutil.parser.parse(tender_period['endDate'])
    data = {
        'EndPeriod': {
            # 'date': end_period.strftime("%m/%d/%Y %H:%M"),
            'date': end_period.strftime("%d.%m.%Y %H:%M"),
            # 'time': end_period.strftime("%H:%M"),
        },
        'StartDate': {
            # 'date': start_dt.strftime("%m/%d/%Y %H:%M"),
            'date': start_dt.strftime("%d.%m.%Y %H:%M"),
            # 'time': start_dt.strftime("%H:%M"),
        },
        'EndDate': {
            # 'date': end_dt.strftime("%m/%d/%Y %H:%M"),
            'date': end_dt.strftime("%d.%m.%Y %H:%M"),
            # 'time': end_dt.strftime("%H:%M"),
        },
    }
    dt = data.get(key, {})
    return dt.get(subkey) if subkey else dt


def convert_date_to_format(isodate):
    iso_dt = parse_date(isodate)
    # date_string = iso_dt.strftime("%m/%d/%Y")
    date_string = iso_dt.strftime("%d.%m.%Y")
    return date_string


def convert_datetime_for_delivery(isodate):
    iso_dt = parse_date(isodate)
    date_string = iso_dt.strftime("%Y.%m.%d %H:%M")
    return date_string


def convert_time_to_format(isodate):
    iso_dt = parse_date(isodate)
    time_string = iso_dt.strftime("%H:%M")
    return time_string


def string_to_float(string):
    return float(string)


def change_data(initial_data):
    initial_data['data']['items'][0]['deliveryAddress']['locality'] = u"м. Київ"
    initial_data['data']['items'][0]['deliveryAddress']['region'] = u"Київська область"
    initial_data['data']['items'][0]['classification']['description'] = u"Картонні коробки"
    initial_data['data']['procuringEntity']['name'] = u"Степанов-Зайцева"
    initial_data['data']['minimalStep']['amount'] = 750.11
    return initial_data


def convert_string_to_common_string(string):
    return {
        u"Київська область": u"м. Київ",
        u"Київ": u"м. Київ",
        u"кг.": u"кілограм",
        u"грн.": u"UAH",
        u"(включаючи ПДВ)": True,
        500.01: 100.1,
    }.get(string, string)


def get_tender_id(str_tender_id):
    substr = u"Інформація про закупівлю "
    index = 0
    length = len(substr)
    while string.find(str_tender_id, substr) != -1:
        index = string.find(str_tender_id, substr)
        str_tender_id = str_tender_id[0:index] + str_tender_id[index + length:]
    return str_tender_id
