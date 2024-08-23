import fetch from 'node-fetch';
import { load } from 'cheerio';
import { Criminal } from '../schema/criminal.js';

const headers = {
    Accept: 'text/html',
    'Accept-Language': 'uk-UA,uk;q=0.9,ru;q=0.8,en-US;q=0.7,en;q=0.6',
    'User-Agent':
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/84.0.4147.135 Safari/537.36',
};

export async function collectURLs(page: number): Promise<string[]> {
    const response = await fetch(`https://ssu.gov.ua/u-rozshuku?page=${page}`, {
        headers,
    });

    const html = await response.text();
    const $ = load(html);

    const urls: string[] = [];
    $('ul.wanted-list > li > a').each((index, element) => {
        const href = element.attribs['href'];
        if (href) {
            urls.push(href.startsWith('/') ? `https://ssu.gov.ua${href}` : href);
        }
    });

    return urls;
}

export async function countPages(): Promise<number> {
    const response = await fetch('https://ssu.gov.ua/u-rozshuku', {
        headers,
    });

    const html = await response.text();
    const $ = load(html);
    const url = $('main ol.pagination > li:last-child > a').attr('href');
    const matches = url?.match(/\bpage=(\d+)/);
    if (matches) {
        return +matches[1];
    }

    return 1;
}

export async function getCriminalDetails(url: string): Promise<Criminal | null> {
    const response = await fetch(url, {
        headers,
    });

    const html = await response.text();
    const $ = load(html);

    const photo = $('main.wanted-page img.person-photo').attr('src');
    const props = $('main.wanted-page .person-prop > .value');

    const items: string[] = [];
    props.each((index, element) => {
        items.push($(element).text().trim());
    });

    if (items.length !== 10) {
        return null;
    }

    return {
        fullname: [items[0], items[1], items[2]].filter(Boolean).join(' '),
        surname: items[0],
        name: items[1],
        patronymic: items[2],
        dob: items[3],
        sex: items[4],
        ddate: items[5],
        dplace: items[6],
        deterrence: items[7],
        article: items[8],
        contact: items[9],
        photo: photo ?? null,
        url,
    };
}
