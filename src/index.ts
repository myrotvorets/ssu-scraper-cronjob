/* eslint-disable no-await-in-loop */
import { EventEmitter } from 'node:events';
import { setTimeout } from 'node:timers/promises';
import mongoose from 'mongoose';
import { cleanEnv, url } from 'envalid';
import CriminalModel from './schema/criminal.js';
import { collectURLs, countPages, getCriminalDetails } from './lib/scraper.js';

(async (): Promise<void> => {
    const env = cleanEnv(process.env, { MONGODB_CONNECTION_STRING: url() });

    EventEmitter.defaultMaxListeners = 20;

    try {
        const connection = await mongoose.connect(env.MONGODB_CONNECTION_STRING, {
            maxPoolSize: 1,
        });

        const pages = await countPages();
        await CriminalModel.deleteMany({});
        await setTimeout(500);
        for (let i = 1; i <= pages; ++i) {
            const urls = await collectURLs(i);
            await setTimeout(500);
            for (const url of urls) /* NOSONAR */ {
                const criminal = await getCriminalDetails(url);
                if (criminal) {
                    const model = new CriminalModel(criminal);
                    await model.save();
                }

                await setTimeout(500);
            }
        }

        await mongoose.connection.db?.collection('new_criminals').rename('criminals', { dropTarget: true });
        await connection.disconnect();
    } catch (e) {
        console.error(e);
        process.exit(1);
    }
})().catch((err: unknown) => {
    console.error(err);
    process.exitCode = 1;
});
