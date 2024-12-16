export function parseDOB(s: string): string | null {
    const lut: Record<string, string> = {
        січня: '01',
        лютого: '02',
        березня: '03',
        квітня: '04',
        травня: '05',
        червня: '06',
        липня: '07',
        серпня: '08',
        вересня: '09',
        жовтня: '10',
        листопада: '11',
        грудня: '12',
    };

    s = s.toLowerCase();
    const matches = /(\d{1,2})\s+(\S+)\s+(\d{4})/u.exec(s);
    if (matches) {
        const day = matches[1].padStart(2, '0');
        const month: string | undefined = lut[matches[2]];
        const year = matches[3];

        if (day && month && year) {
            return `${year}-${month}-${day}`;
        }
    }

    return null;
}

export function parseSex(s: string): string {
    switch (s.toLowerCase()) {
        case 'чоловіча':
            return 'M';

        case 'жіноча':
            return 'F';

        default:
            return s;
    }
}

export function parseDDate(s: string): string | null {
    return s === '0000-00-00 00:00:00' || s === '-' ? null : parseDOB(s);
}
