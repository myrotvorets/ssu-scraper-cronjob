import { EventEmitter } from 'node:events';
import { promisify } from 'util';
import mongoose from 'mongoose';
import { cleanEnv, url } from 'envalid';
import CriminalModel from './schema/criminal.js';
import { countPages, collectURLs, getCriminalDetails } from './lib/scraper.js';

const wait = promisify(setTimeout);

(async () => {
    const env = cleanEnv(process.env, { MONGODB_CONNECTION_STRING: url() });

    EventEmitter.defaultMaxListeners = 20;

    try {
        const connection = await mongoose.connect(env.MONGODB_CONNECTION_STRING, {
            maxPoolSize: 1,
        });

        const pages = await countPages();
        await CriminalModel.deleteMany({});
        await wait(500);
        for (let i = 1; i <= pages; ++i) {
            const urls = await collectURLs(i);
            await wait(500);
            for (const url of urls) /* NOSONAR */ {
                const criminal = await getCriminalDetails(url);
                if (criminal) {
                    const model = new CriminalModel(criminal);
                    await model.save();
                }

                await wait(500);
            }
        }

        await mongoose.connection.db.collection('new_criminals').rename('criminals', { dropTarget: true });
        await connection.disconnect();
    } catch (e) {
        console.error(e);
        process.exit(1);
    }
})();
