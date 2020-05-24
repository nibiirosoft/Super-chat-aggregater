#!/usr/bin/env python3
# -*- coding: utf-8 -*-

'''
Author: Siqi Deng, deng47@gmail.com
Version: 1.1 10/12/2018
https://github.com/deng47/super_chat_calculator/blob/master/super_chat_calculaor.py
'''


import requests
import datetime
import re
import json
import sys
import io

sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')

def str_to_money(str):
    str = str.replace(',','')
    currency = re.findall('(.*?)\d+',str)[0]
    amount = float(re.findall('\d+',str)[0])
    return {currency:amount}


def get_live_comment_link(url):
    global session, basic_linka, lengthSeconds, startTimestamp

    start_link = "https://www.youtube.com/live_chat_replay?continuation="
    html = session.get(url, headers=headers).text

    if re.search('\"isLiveContent\":false', html):
        print('Warning: video is not live content.', file=sys.stderr)
        sys.exit(1)
    if re.search('\"isLiveNow\":true', html):
        print('Warning: live is not finished.', file=sys.stderr)
        sys.exit(1)
    if not re.search('"liveChatRenderer":', html):
        print('Warning: live chat is not supported.', file=sys.stderr)
        sys.exit(1)
    startTimestamp = re.findall('\"startTimestamp\":\"(.*?)\"', html)
    if len(startTimestamp) == 0:
        print('Error: "startTimestamp" was not found.', file=sys.stderr)
        sys.exit(1)
    startTimestamp = startTimestamp[0]
    startTimestamp = datetime.datetime.strptime(startTimestamp, '%Y-%m-%dT%H:%M:%S+00:00') + datetime.timedelta(hours=9)
    if startTimestamp > datetime.datetime.now():
        print('Warning: live is not finished.', file=sys.stderr)
        sys.exit(1)
    continuation = re.findall('"continuation":"(.*?)"', html)
    if len(continuation) < 3:
        print('Error: "continuation" was not found.', file=sys.stderr)
        sys.exit(1)
    continuation = continuation[2]
    lengthSeconds = int(re.findall('\"lengthSeconds\":\"(\d+)\"', html)[0])

    next_link = start_link + continuation + '&hidden=false&pbj=1'
    html = session.get(next_link, headers=headers).text

    extract_superchat(json.loads(html)[1]["response"])
    continuation = json.loads(html)[1]['response']["continuationContents"]["liveChatContinuation"]["continuations"][0]
    if 'liveChatReplayContinuationData' in continuation:
        continuation = continuation["liveChatReplayContinuationData"]["continuation"]
    elif 'playerSeekContinuationData' in continuation:
        print('Error: "liveChatReplayContinuationData" was not found.', file=sys.stderr)
        sys.exit(1)
        continuation = continuation["playerSeekContinuationData"]["continuation"]
    else:
        print('Error: "liveChatReplayContinuationData" was not found.', file=sys.stderr)
        sys.exit(1)
    next_link = basic_link + continuation + '&hidden=false&pbj=1'
    return next_link


def extract_superchat(json_data):
    global last_timestamp, timestamp, last_superchat, currencies, all
    for each in json_data["continuationContents"]["liveChatContinuation"]["actions"]:
        timestamp = int(each["replayChatItemAction"]["videoOffsetTimeMsec"])
        if "addChatItemAction" in each["replayChatItemAction"]["actions"][0]:
            if  'liveChatPaidMessageRenderer' in  each["replayChatItemAction"]["actions"][0]["addChatItemAction"]['item']:
                raw_info = each["replayChatItemAction"]["actions"][0]["addChatItemAction"]['item']['liveChatPaidMessageRenderer']

                if 'message' in raw_info:
                    if 'text' in raw_info['message']['runs'][0]:
                        message = raw_info['message']['runs'][0]['text']
                    if 'emoji' in raw_info['message']['runs'][0]:
                        message = raw_info['message']['runs'][0]['emoji']['shortcuts'][0]
                else:
                    message = ''
            elif 'liveChatPaidStickerRenderer' in  each["replayChatItemAction"]["actions"][0]["addChatItemAction"]['item']:
                raw_info = each["replayChatItemAction"]["actions"][0]["addChatItemAction"]['item']['liveChatPaidStickerRenderer']

                message = ':' + raw_info['sticker']['accessibility']['accessibilityData']['label'] + ':'
            else:
                continue

            supporter = raw_info['authorName']['simpleText']
            amount = raw_info['purchaseAmountText']['simpleText']
            time = raw_info["timestampText"]['simpleText']
            minusFlg = 1
            if time[0:1] == '-':
                time = time[1:]
                minusFlg = -1
            if len(re.findall(':', time)) == 1:
                time2 = datetime.datetime.strptime(time, '%M:%S')
            elif len(re.findall(':', time)) == 2:
                time2 = datetime.datetime.strptime(time, '%H:%M:%S')
            timestampText = startTimestamp + (datetime.timedelta(hours=time2.hour) + datetime.timedelta(minutes=time2.minute) + datetime.timedelta(seconds=time2.second)) * minusFlg
            timestampText = timestampText.strftime('%Y-%m-%d %H:%M:%S')

            if last_timestamp <= timestamp and last_superchat != time+supporter+amount:
                last_timestamp = timestamp
                last_superchat = time+supporter+amount
                money = str_to_money(amount)
                currency = [key for key in money.keys()][0]

                print("%s	%s	%s	%s	%.2f	%s" % (video_id, timestampText, supporter, currency, money[currency], message))

all = {}
currencies = {}
last_timestamp = 0
last_superchat = ""
jump_to = 0

video_link = sys.argv[1]
video_id = re.findall('v=(.*)$', video_link)[0]

headers = {'user-agent': 'Mozilla/5.0 (Windows NT 6.1; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/69.0.3497.100 Safari/537.36'}
basic_link = "https://www.youtube.com/live_chat_replay/get_live_chat_replay?continuation="

session = requests.Session()
next_link = get_live_comment_link(video_link)


while next_link != '':
    html = session.get(next_link, headers=headers).text
    data = json.loads(html)['response']
    if "continuationContents" not in data:
        jump_to += 1
        if (timestamp//1000)+ jump_to >= lengthSeconds:
            break
        next_link = get_live_comment_link(video_link + "&t=%ss" % str((timestamp//1000)+ jump_to))
        continue
    json_response = data["continuationContents"]["liveChatContinuation"]
    if "liveChatReplayContinuationData" in json_response["continuations"][0]:
        continuation = json_response["continuations"][0]["liveChatReplayContinuationData"]["continuation"]
        next_link = basic_link + continuation + '&hidden=false&pbj=1'
        extract_superchat(data)

    else:
        jump_to += 1
        if (timestamp//1000)+ jump_to >= lengthSeconds:
            break
        next_link = get_live_comment_link(video_link + "&t=%ss" % str((timestamp//1000)+ jump_to))
